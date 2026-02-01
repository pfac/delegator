defmodule Delegator do
  defmacro __using__(opts) do
    targets =
      case Keyword.fetch!(opts, :to) do
        nil -> raise ArgumentError, ":to is required"
        [] -> raise ArgumentError, ":to must not be empty"
        [_ | _] = targets -> targets
        {_, _, _} = target -> [target]
      end

    except =
      case Keyword.get(opts, :except) do
        nil -> nil
        funs -> MapSet.new(funs)
      end

    only =
      case Keyword.get(opts, :only) do
        nil -> nil
        funs -> MapSet.new(funs)
      end

    aliases = Delegator.aliases(opts)
    prefix = Keyword.get(opts, :prefix)
    suffix = Keyword.get(opts, :suffix)

    for target <- targets do
      functions =
        target
        |> Macro.expand(__CALLER__)
        |> Kernel.apply(:__info__, [:functions])
        |> MapSet.new()
        |> then(&if is_nil(except), do: &1, else: MapSet.difference(&1, except))
        |> then(&if is_nil(only), do: &1, else: MapSet.intersection(&1, only))

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
        end
      end
    end
  end

  def aliases(opts) do
    entries =
      case opts[:as] do
        nil -> []
        {:%{}, _, kw} -> kw
        kw -> kw
      end

    Map.new(entries, fn
      {{fun_name, fun_arity}, fun_alias} -> {{"#{fun_name}", fun_arity}, "#{fun_alias}"}
      {fun_name, fun_alias} -> {"#{fun_name}", "#{fun_alias}"}
    end)
  end

  def delegate_name({fun_name, fun_arity}, aliases, prefix, suffix) do
    with nil <- aliases["#{fun_name}"] || aliases[{"#{fun_name}", fun_arity}] do
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
