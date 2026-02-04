defmodule Delegator do
  alias Delegator.AliasesMap
  alias Delegator.Definitions
  alias Delegator.Opts

  defmacro __using__(opts) do
    header =
      quote do
        import unquote(__MODULE__)
      end

    targets =
      case Keyword.fetch!(opts, :to) do
        nil -> raise ArgumentError, ":to is required"
        [] -> raise ArgumentError, ":to must not be empty"
        [_ | _] = targets -> targets
        {_, _, _} = target -> [target]
      end

    delegates =
      for target <- targets do
        quote do: defdelegateeverything(unquote(target), unquote(opts))
      end

    [header | delegates]
  end

  defmacro __delegateall__(type, target, opts \\ []) do
    aliases = Opts.aliases(opts)
    except = Opts.except(opts)
    only = Opts.only(opts)
    prefix = Opts.prefix(opts)
    suffix = Opts.suffix(opts)

    definitions =
      target
      |> Macro.expand(__CALLER__)
      |> Kernel.apply(:__info__, [type])
      |> then(&if is_nil(except), do: &1, else: Definitions.except(&1, except))
      |> then(&if is_nil(only), do: &1, else: Definitions.only(&1, only))

    pos_ints = Stream.iterate(1, &(&1 + 1))

    {delegated, delegations} =
      for {name, arity} <- definitions do
        delegate_name =
          {name, arity}
          |> Delegator.delegate_name(aliases, prefix, suffix)
          |> String.to_atom()

        args =
          pos_ints
          |> Stream.take(arity)
          |> Stream.map(&"arg#{&1}")
          |> Stream.map(&String.to_atom/1)
          |> Enum.map(&{&1, [], nil})

        {delegate_mod, delegate_macro} =
          case type do
            :functions -> {Kernel, :defdelegate}
            :macros -> {Delegator, :defdelegatemacro}
          end

        delegation =
          quote do
            unquote(delegate_mod).unquote(delegate_macro)(
              unquote(delegate_name)(unquote_splicing(args)),
              to: unquote(target),
              as: unquote(name)
            )
          end

        {{delegate_name, arity}, delegation}
      end
      |> Enum.unzip()

    overrides =
      if type === :functions do
        quote do: defoverridable(unquote(delegated))
      end

    delegations ++ [overrides]
  end

  defmacro defdelegateall(target, opts \\ []) do
    quote do: Delegator.__delegateall__(:functions, unquote(target), unquote(opts))
  end

  defmacro defdelegatemacro({name, _, args}, opts \\ []) do
    as = Keyword.get(opts, :as, name)

    to =
      with nil <- Keyword.get(opts, :to) do
        raise ArgumentError, ":to is required"
      end

    quote do
      defmacro unquote(name)(unquote_splicing(args)) do
        as = unquote(as)
        to = unquote(to)
        args = unquote(args)

        quote do
          require unquote(to)
          unquote(to).unquote(as)(unquote_splicing(args))
        end
      end
    end
  end

  defmacro defdelegateallmacros(target, opts \\ []) do
    quote do: Delegator.__delegateall__(:macros, unquote(target), unquote(opts))
  end

  defmacro defdelegateeverything(target, opts \\ []) do
    quote do
      defdelegateall unquote(target), unquote(opts)
      defdelegateallmacros unquote(target), unquote(opts)
    end
  end

  def delegate_name({name, arity}, aliases, prefix, suffix) do
    name = to_string(name)

    with nil <- AliasesMap.get(aliases, {name, arity}) do
      name |> prefix_fun_name(prefix) |> suffix_fun_name(suffix)
    end
  end

  defp prefix_fun_name(fun_name, prefix) do
    cond do
      "#{prefix}" == "" -> fun_name
      String.starts_with?(fun_name, "_") -> prefix <> fun_name
      true -> "#{prefix}_#{fun_name}"
    end
  end

  defp suffix_fun_name(fun_name, suffix) do
    cond do
      "#{suffix}" == "" -> fun_name
      String.ends_with?(fun_name, "_") -> fun_name <> suffix
      true -> "#{fun_name}_#{suffix}"
    end
  end
end
