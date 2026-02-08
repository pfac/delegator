defmodule Delegator.AliasesMap do
  @moduledoc """
  Maps definitions to the provided alias.
  """

  defstruct aliases: %{}

  @doc """
  Get the alias for a given definition.

  Any alias using the wildcard `:*` supersedes an entry for a specific arity.
  """
  def get(%__MODULE__{aliases: aliases}, {name, arity}, default \\ nil) do
    name = to_string(name)

    aliases[{name, :*}] || aliases[{name, arity}] || default
  end

  @doc """
  Creates an aliases map from an enumerable.

  Items in the enumerable must be one of:

  * `{{name, arity}, alias}` - maps a specific definition to an alias;
  * `{name, alias}` - maps all defitions with the same name to an alias.

  Names and aliases may be strings or atoms. Internally both are stored as
  strings.

  ## Examples

      iex> Delegator.AliasesMap.new()
      #Delegator.AliasesMap<aliases: %{}>

      iex> Delegator.AliasesMap.new([])
      #Delegator.AliasesMap<aliases: %{}>

      iex> Delegator.AliasesMap.new([a: :c])
      #Delegator.AliasesMap<aliases: %{{"c", :*} => "a"}>

      iex> Delegator.AliasesMap.new(%{{:a, 1} => :c})
      #Delegator.AliasesMap<aliases: %{{"c", 1} => "a"}>

      iex> Delegator.AliasesMap.new(%{[a: 1, a: 2] => :c})
      #Delegator.AliasesMap<aliases: %{{"c", 1} => "a", {"c", 2} => "a"}>
  """
  def new(enumerable \\ []) do
    aliases =
      Enum.reduce(enumerable, %{}, fn
        # %{[a: 1, a: 2, ...] => :c}
        {defs, to}, acc when is_list(defs) ->
          Enum.reduce(defs, acc, fn {from, arity}, acc2 ->
            Map.put(acc2, {"#{to}", arity}, "#{from}")
          end)

        # %{{:a, 1} => :c}
        {{from, arity}, to}, acc ->
          Map.put(acc, {"#{to}", arity}, "#{from}")

        # %{a: :c}
        # [a: :c]
        {from, to}, acc ->
          Map.put(acc, {"#{to}", :*}, "#{from}")
      end)

    %__MODULE__{aliases: aliases}
  end
end

defimpl Inspect, for: Delegator.AliasesMap do
  import Inspect.Algebra

  def inspect(%Delegator.AliasesMap{} = aliases_map, opts) do
    list = [{:aliases, aliases_map.aliases}]

    container_doc("#Delegator.AliasesMap<", list, ">", %{limit: 5}, fn
      {:aliases, aliases}, _opts ->
        concat("aliases: ", to_doc(aliases, opts))
    end)
  end
end
