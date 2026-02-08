defmodule Delegator.Opts do
  @moduledoc """
  Shared module for consistent options handling in Delegator.
  """

  alias Delegator.AliasesMap
  alias Delegator.AritiesMap

  @doc """
  Extract aliases from option `:as`.

  Supports both keyword lists and maps. The keys may be a function name (string
  or atom), in which case it will be applied to all functions with this name
  regardless of its arity. The keys may also be a tuple function name-arity, in
  which case the alias applies only to that specific function. The value of the
  entries may be a string or atom.

  Returns a `Delegator.AliasesMap`. Returns `nil` whether the option is not
  provided or explicitly set so.

  ## Examples

      iex> Delegator.Opts.aliases(as: %{a: :c})
      #Delegator.AliasesMap<aliases: %{{"c", :*} => "a"}>

      iex> Delegator.Opts.aliases(as: [a: "c"])
      #Delegator.AliasesMap<aliases: %{{"c", :*} => "a"}>

      iex> Delegator.Opts.aliases(as: %{"a" => "c"})
      #Delegator.AliasesMap<aliases: %{{"c", :*} => "a"}>

      iex> Delegator.Opts.aliases(as: %{{:a, 1} => :c})
      #Delegator.AliasesMap<aliases: %{{"c", 1} => "a"}>

      iex> Delegator.Opts.aliases(as: [{{:a, 1}, :c}])
      #Delegator.AliasesMap<aliases: %{{"c", 1} => "a"}>
  """
  def aliases(opts) do
    aliases =
      case opts[:as] do
        nil -> []
        {:%{}, _, kw} -> kw
        kw -> kw
      end

    AliasesMap.new(aliases)
  end

  defp arities_map(nil), do: nil
  defp arities_map(val), do: AritiesMap.new(val)

  @doc """
  Extract arities map to exclude from option `:except`.

  Returns `nil` if the option is unset, or set explicitly. Otherwise the option
  value is passed to `Delegator.AritiesMap.new/1`.

  ## Examples

      iex> Delegator.Opts.except(except: [])
      #Delegator.AritiesMap<entries: %{}>

      iex> Delegator.Opts.except(except: :a)
      #Delegator.AritiesMap<entries: %{"a" => :*}>

      iex> Delegator.Opts.except(except: [a: 1, a: 2])
      #Delegator.AritiesMap<entries: %{"a" => [1, 2]}>
  """
  def except(opts), do: opts |> Keyword.get(:except) |> arities_map()

  @doc """
  Extract arities map to include from option `:only`.

  Returns `nil` if the option is unset, or set explicitly. Otherwise the option
  value is passed to `Delegator.AritiesMap.new/1`.

  ## Examples

      iex> Delegator.Opts.only(only: [])
      #Delegator.AritiesMap<entries: %{}>

      iex> Delegator.Opts.only(only: :a)
      #Delegator.AritiesMap<entries: %{"a" => :*}>

      iex> Delegator.Opts.only(only: [a: 1, a: 2])
      #Delegator.AritiesMap<entries: %{"a" => [1, 2]}>
  """
  def only(opts), do: opts |> Keyword.get(:only) |> arities_map()

  @doc """
  Extract the prefix to use for delegates.

  Supports both atoms and strings.

  ## Examples

      iex> Delegator.Opts.prefix(prefix: :before)
      "before"

      iex> Delegator.Opts.prefix(prefix: "before")
      "before"
  """
  def prefix(opts), do: opts |> Keyword.get(:prefix) |> to_string()

  @doc """
  Extract the suffix to use for delegates.

  Supports both atoms and strings.

  ## Examples

      iex> Delegator.Opts.suffix(suffix: :after)
      "after"

      iex> Delegator.Opts.suffix(suffix: "after")
      "after"
  """
  def suffix(opts), do: opts |> Keyword.get(:suffix) |> to_string()

  @doc """
  Extract the module to delegate to.

  Raises an `ArgumentError` if not set or set to `nil`.

  ## Examples

      iex> Delegator.Opts.to!(to: A)
      A

      iex> Delegator.Opts.to!(to: nil)
      ** (ArgumentError) :to is required
  """
  def to!(opts) do
    with nil <- Keyword.get(opts, :to) do
      raise ArgumentError, ":to is required"
    end
  end
end
