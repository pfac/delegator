defmodule Delegator.Functions do
  alias Delegator.AritiesMap

  @doc """
  Removes from a module's functions list the entries in an arities map.

  Functions set with an wildcard are completely removed. Functions not in the
  map, or arities not in the map, are kept.

  ## Examples

      iex> functions = [a: 1, a: 2, b: 1]
      iex> arities_map = Delegator.AritiesMap.new()
      iex> Delegator.Functions.except(functions, arities_map)
      [a: 1, a: 2, b: 1]

      iex> functions = [a: 1, a: 2, b: 1]
      iex> arities_map = Delegator.AritiesMap.new(a: 1)
      iex> Delegator.Functions.except(functions, arities_map)
      [a: 2, b: 1]

      iex> functions = [a: 1, a: 2, b: 1]
      iex> arities_map = Delegator.AritiesMap.new(:a)
      iex> Delegator.Functions.except(functions, arities_map)
      [b: 1]

  """
  def except(functions, %AritiesMap{} = arities_map) do
    Enum.reject(functions, fn {fun_name, fun_arity} ->
      case AritiesMap.get(arities_map, fun_name) do
        nil -> false
        :* -> true
        arities -> fun_arity in arities
      end
    end)
  end

  @doc """
  Filters a module's functions list to those in an arities map.

  Functions set with an wildcard keep all listed arities. Functions not in the
  map, or arities not in the map, are excluded.

  ## Examples

      iex> functions = [a: 1, a: 2, b: 1]
      iex> arities_map = Delegator.AritiesMap.new()
      iex> Delegator.Functions.only(functions, arities_map)
      []

      iex> functions = [a: 1, a: 2, b: 1]
      iex> arities_map = Delegator.AritiesMap.new(a: 1)
      iex> Delegator.Functions.only(functions, arities_map)
      [a: 1]

      iex> functions = [a: 1, a: 2, b: 1]
      iex> arities_map = Delegator.AritiesMap.new(:a)
      iex> Delegator.Functions.only(functions, arities_map)
      [a: 1, a: 2]

  """
  def only(functions, %AritiesMap{} = arities_map) do
    Enum.filter(functions, fn {fun_name, fun_arity} ->
      case AritiesMap.get(arities_map, fun_name) do
        nil -> false
        :* -> true
        arities -> fun_arity in arities
      end
    end)
  end
end
