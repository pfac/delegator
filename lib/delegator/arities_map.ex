defmodule Delegator.AritiesMap do
  @moduledoc """
  Data structure to record the arities of functions to include/exclude from
  delegation.

  It uses a regular map, where keys are the function names as strings, and the
  values are either `:*` or a set of arities for that function.

  All functions treat atoms and strings equally, i.e. function name `:a` is the
  same as function name `"a"`.
  """

  defstruct entries: %{}

  @doc """
  Returns the number of entries in the arities map.
  """
  def count(%__MODULE__{} = am), do: Enumerable.count(am.entries)

  @doc """
  Fetch the arities for a specific function name.

  Returns `{:ok, arities}` if there is an entry for the provided function name,
  otherwise returns `:error`.

  ## Examples

      iex> Delegator.AritiesMap.new(:a)
      ...> |> Delegator.AritiesMap.fetch(:a)
      {:ok, :*}

      iex> Delegator.AritiesMap.new(:a)
      ...> |> Delegator.AritiesMap.fetch("a")
      {:ok, :*}

      iex> Delegator.AritiesMap.new(a: 1, a: 2)
      ...> |> Delegator.AritiesMap.fetch("a")
      {:ok, [1, 2]}

      iex> Delegator.AritiesMap.new()
      ...> |> Delegator.AritiesMap.fetch(:a)
      :error
  """
  def fetch(%__MODULE__{} = arities_map, fun_name) do
    with {:ok, %MapSet{} = arities_set} <- Map.fetch(arities_map.entries, "#{fun_name}") do
      {:ok, MapSet.to_list(arities_set)}
    end
  end

  @doc """
  Get the arities for a specific function name.

  If there's no entry for the provided function name, returns the default value.

  ## Examples

      iex> Delegator.AritiesMap.new(:a)
      ...> |> Delegator.AritiesMap.get(:a)
      :*

      iex> Delegator.AritiesMap.new(:a)
      ...> |> Delegator.AritiesMap.get("a")
      :*

      iex> Delegator.AritiesMap.new(a: 1, a: 2)
      ...> |> Delegator.AritiesMap.get("a")
      [1, 2]

      iex> Delegator.AritiesMap.new()
      ...> |> Delegator.AritiesMap.get(:a)
      nil

      iex> Delegator.AritiesMap.new()
      ...> |> Delegator.AritiesMap.get(:a, :not_found)
      :not_found
  """
  def get(%__MODULE__{} = arities_map, fun_name, default \\ nil) do
    with %MapSet{} = arities_set <- Map.get(arities_map.entries, "#{fun_name}", default) do
      MapSet.to_list(arities_set)
    end
  end

  @doc """
  Checks whether an entry exists for a function name in the arities map.

  Membership is tested with the match (===/2) operator.
  """
  def member?(%__MODULE__{} = am, fun_name), do: Enumerable.member?(am.entries, fun_name)

  @doc """
  Build a new arities map.

  If provided, arities may be a single function name, or an enumerablei. As an
  enumerable it may contain function names, or function name-arity pairs, in any
  combination.

  Names without arity, or arities using the wildcard `:*` will affect all
  functions with that name, regardless of the arity. Such an entry supersedes
  any other entries with a similar function name.

  ## Examples

      iex> Delegator.AritiesMap.new()
      #Delegator.AritiesMap<entries: %{}>

      iex> Delegator.AritiesMap.new(:a)
      #Delegator.AritiesMap<entries: %{"a" => :*}>

      iex> Delegator.AritiesMap.new(a: 1, a: 2)
      #Delegator.AritiesMap<entries: %{"a" => [1, 2]}>

      iex> Delegator.AritiesMap.new([:a, b: 1, b: 2])
      #Delegator.AritiesMap<entries: %{"a" => :*, "b" => [1, 2]}>
  """
  def new(arities \\ []) do
    Enum.reduce(arities, %__MODULE__{}, fn
      {k, v}, acc -> put(acc, k, v)
      k, acc -> put(acc, k, :*)
    end)
  rescue
    Protocol.UndefinedError -> new([arities])
  end

  @doc """
  Add function to an arities map.

  The provided function arity is add to a set under the function name key.

  The wildcard value overwrites any pre-defined set, and can not be overwritten.

  ## Examples

      iex> Delegator.AritiesMap.put(%Delegator.AritiesMap{}, :a)
      #Delegator.AritiesMap<entries: %{"a" => :*}>

      iex> Delegator.AritiesMap.put(%Delegator.AritiesMap{}, :a, 1)
      #Delegator.AritiesMap<entries: %{"a" => [1]}>

      iex> %Delegator.AritiesMap{}
      ...> |> Delegator.AritiesMap.put(:a, 1)
      ...> |> Delegator.AritiesMap.put(:a)
      ...> |> Delegator.AritiesMap.put(:a, 2)
      #Delegator.AritiesMap<entries: %{"a" => :*}>
  """
  def put(arities_map, fun_name, fun_arity \\ :*)

  def put(%__MODULE__{} = arities_map, fun_name, :*) do
    Map.update!(arities_map, :entries, &Map.put(&1, "#{fun_name}", :*))
  end

  def put(%__MODULE__{} = arities_map, fun_name, fun_arity) do
    fun_name = "#{fun_name}"

    fun_arities =
      case arities_map.entries[fun_name] do
        :* -> :*
        nil -> MapSet.new([fun_arity])
        %MapSet{} = fun_arities -> MapSet.put(fun_arities, fun_arity)
      end

    Map.update!(arities_map, :entries, &Map.put(&1, fun_name, fun_arities))
  end

  @doc """
  Invokes a function for each entry in the arities map with the accumulator.

  The initial value of the accumulator is acc. The function is invoked for each
  entry in the enumerable with the accumulator. The result returned by the
  function is used as the accumulator for the next iteration. The function
  returns the last accumulator.
  """
  def reduce(%__MODULE__{} = am, acc, fun), do: Enumerable.reduce(am.entries, acc, fun)

  @doc """
  Returns a function that slices the arities map contiguously.
  """
  def slice(%__MODULE__{} = am) do
    with {:ok, size, _fun} <- Enumerable.slice(am.entries) do
      {:ok, size, &to_list/1}
    end
  end

  @doc """
  Returns a list of pairs with the function name-arities pairs in the entries.

  Pairs are ordered by the function name, alphabetically.

  ## Examples

      iex> Delegator.AritiesMap.new()
      ...> |> Delegator.AritiesMap.to_list()
      []

      iex> Delegator.AritiesMap.new(a: 1, b: :*)
      ...> |> Delegator.AritiesMap.to_list()
      [{"a", [1]}, {"b", :*}]

      iex> Delegator.AritiesMap.new(b: :*, a: 1)
      ...> |> Delegator.AritiesMap.to_list()
      [{"a", [1]}, {"b", :*}]
  """
  def to_list(%__MODULE__{} = am) do
    am.entries
    |> Enum.reduce([], fn
      {k, :*}, acc -> [{k, :*} | acc]
      {k, %MapSet{} = v}, acc -> [{k, MapSet.to_list(v)} | acc]
    end)
    |> Enum.sort_by(fn {k, _} -> k end)
  end
end

defimpl Inspect, for: Delegator.AritiesMap do
  import Inspect.Algebra

  def inspect(%Delegator.AritiesMap{} = arities_map, opts) do
    list = [{:entries, arities_map.entries}]

    container_doc("#Delegator.AritiesMap<", list, ">", %{limit: 5}, fn
      {:entries, entries}, _opts ->
        entries
        |> Map.new(fn
          {fun_name, %MapSet{} = arities_set} -> {fun_name, MapSet.to_list(arities_set)}
          entry -> entry
        end)
        |> then(&concat("entries: ", to_doc(&1, opts)))
    end)
  end
end
