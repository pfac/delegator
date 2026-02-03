defmodule Delegator do
  alias Delegator.Functions
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
        quote do: defdelegateall(unquote(target), unquote(opts))
      end

    [header | delegates]
  end

  defmacro defdelegateall(target, opts \\ []) do
    aliases = Opts.aliases(opts)
    except = Opts.except(opts)
    only = Opts.only(opts)
    prefix = Opts.prefix(opts)
    suffix = Opts.suffix(opts)

    functions =
      target
      |> Macro.expand(__CALLER__)
      |> Kernel.apply(:__info__, [:functions])
      |> then(&if is_nil(except), do: &1, else: Functions.except(&1, except))
      |> then(&if is_nil(only), do: &1, else: Functions.only(&1, only))

    pos_ints = Stream.iterate(1, &(&1 + 1))

    for {fun_name, fun_arity} <- functions do
      delegate_name =
        {fun_name, fun_arity}
        |> Delegator.delegate_name(aliases, prefix, suffix)
        |> String.to_atom()

      fun_args =
        pos_ints
        |> Stream.take(fun_arity)
        |> Stream.map(&"arg#{&1}")
        |> Stream.map(&String.to_atom/1)
        |> Enum.map(&{&1, [], nil})

      quote do
        defdelegate unquote(delegate_name)(unquote_splicing(fun_args)),
          to: unquote(target),
          as: unquote(fun_name)

        defoverridable [{unquote(delegate_name), unquote(fun_arity)}]
      end
    end
  end

  def delegate_name({fun_name, fun_arity}, aliases, prefix, suffix) do
    with nil <- aliases[{"#{fun_name}", :*}] || aliases[{"#{fun_name}", fun_arity}] do
      "#{fun_name}" |> prefix_fun_name(prefix) |> suffix_fun_name(suffix)
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
