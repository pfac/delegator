defmodule Delegator do
  defmacro __using__(opts) do
    target = Keyword.fetch!(opts, :to)
    functions = target |> Macro.expand(__CALLER__) |> Kernel.apply(:__info__, [:functions])
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
