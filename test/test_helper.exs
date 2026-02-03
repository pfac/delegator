defmodule Delegator.Test.Assertions do
  @doc """
  Refutes a module implements any function with a given name.
  """
  defmacro refute_defined(mod, fun) do
    quote do
      refute Keyword.has_key?(unquote(mod).__info__(:functions), unquote(fun))
    end
  end

  @doc """
  Refutes a module implements a specific function.
  """
  defmacro refute_defined(mod, fun, arity) do
    quote do
      refute {unquote(fun), unquote(arity)} in unquote(mod).__info__(:functions)
    end
  end

  @doc """
  Refutes a module implements any macro with a given name.
  """
  defmacro refute_macro(mod, fun) do
    quote do
      refute Keyword.has_key?(unquote(mod).__info__(:macros), unquote(fun))
    end
  end

  @doc """
  Refutes a module implements a specific macro.
  """
  defmacro refute_macro(mod, fun, arity) do
    quote do
      refute {unquote(fun), unquote(arity)} in unquote(mod).__info__(:macros)
    end
  end
end

defmodule Delegator.Test.Case do
  use ExUnit.CaseTemplate

  using do
    quote do
      import Delegator.Test.Assertions
    end
  end
end

ExUnit.start()
