defmodule Delegator.Definitions do
  @moduledoc false

  alias Delegator.AritiesMap

  @doc """
  Removes from a definitions list the entries in an arities map.

  Definitions set with an wildcard are completely removed. Definitions not in the
  map, or arities not in the map, are kept.

  ## Examples

      iex> definitions = [a: 1, a: 2, b: 1]
      iex> arities_map = Delegator.AritiesMap.new()
      iex> Delegator.Definitions.except(definitions, arities_map)
      [a: 1, a: 2, b: 1]

      iex> definitions = [a: 1, a: 2, b: 1]
      iex> arities_map = Delegator.AritiesMap.new(a: 1)
      iex> Delegator.Definitions.except(definitions, arities_map)
      [a: 2, b: 1]

      iex> definitions = [a: 1, a: 2, b: 1]
      iex> arities_map = Delegator.AritiesMap.new(:a)
      iex> Delegator.Definitions.except(definitions, arities_map)
      [b: 1]

  """
  def except(definitions, %AritiesMap{} = arities_map) do
    Enum.reject(definitions, fn {fun_name, fun_arity} ->
      case AritiesMap.get(arities_map, fun_name) do
        nil -> false
        :* -> true
        arities -> fun_arity in arities
      end
    end)
  end

  @doc """
  Filters a definitions list to those in an arities map.

  Definitions set with an wildcard keep all listed arities. Definitions not in the
  map, or arities not in the map, are excluded.

  ## Examples

      iex> definitions = [a: 1, a: 2, b: 1]
      iex> arities_map = Delegator.AritiesMap.new()
      iex> Delegator.Definitions.only(definitions, arities_map)
      []

      iex> definitions = [a: 1, a: 2, b: 1]
      iex> arities_map = Delegator.AritiesMap.new(a: 1)
      iex> Delegator.Definitions.only(definitions, arities_map)
      [a: 1]

      iex> definitions = [a: 1, a: 2, b: 1]
      iex> arities_map = Delegator.AritiesMap.new(:a)
      iex> Delegator.Definitions.only(definitions, arities_map)
      [a: 1, a: 2]

  """
  def only(definitions, %AritiesMap{} = arities_map) do
    Enum.filter(definitions, fn {fun_name, fun_arity} ->
      case AritiesMap.get(arities_map, fun_name) do
        nil -> false
        :* -> true
        arities -> fun_arity in arities
      end
    end)
  end
end
