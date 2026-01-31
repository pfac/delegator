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
        fun_args =
          pos_ints
          |> Stream.take(fun_arity)
          |> Stream.map(&"arg#{&1}")
          |> Stream.map(&String.to_atom/1)
          |> Enum.map(&{&1, [], nil})

        quote do
          defdelegate unquote(fun_name)(unquote_splicing(fun_args)), to: unquote(target)
        end
      end
    end
  end
end
