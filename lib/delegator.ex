defmodule Delegator do
  @moduledoc """
  Delegates functions and macros from one module to another.

  Delegator extends Elixir's built-in delegation mechanism by providing powerful
  macros for delegating multiple functions and macros at once, with fine-grained
  control over which items are delegated and how they are named.

  ## Shared options

  - `:as` - Rename delegated definitions. See `Delegator.AliasesMap.new/1`.
  - `:except` - Exclude specific defintions. See `Delegator.AritiesMap.new/1`.
  - `:only` - Include only specific defintions. See `Delegator.AritiesMap.new/1`.
  - `:prefix` - Add prefix to delegated names. May be an atom or a string.
  - `:suffix` - Add suffix to delegated names. May be an atom or a string.
  - `:to` - Required. Which module to delegate to.

  Passing `nil` to any option causes it to be ignored.

  ## Overrides

  Functions delegated with `defdelegateall` are automatically marked as
  overridable, allowing you to override them in your module.

  Macros are never overridable.
  """

  alias Delegator.AliasesMap
  alias Delegator.Definitions
  alias Delegator.Opts

  @doc false
  defmacro __delegateall__(type, opts \\ []) do
    aliases = Opts.aliases(opts)
    except = Opts.except(opts)
    only = Opts.only(opts)
    prefix = Opts.prefix(opts)
    suffix = Opts.suffix(opts)
    to = Opts.to!(opts)

    definitions =
      to
      |> Macro.expand(__CALLER__)
      |> Kernel.apply(:__info__, [type])
      |> then(&if is_nil(except), do: &1, else: Definitions.except(&1, except))
      |> then(&if is_nil(only), do: &1, else: Definitions.only(&1, only))

    pos_ints = Stream.iterate(1, &(&1 + 1))

    result =
      for {name, arity} <- definitions do
        delegate_name =
          {name, arity}
          |> Delegator.delegate_name(aliases, prefix, suffix)
          |> String.to_atom()

        args =
          pos_ints
          |> Stream.take(arity)
          |> Stream.map(&"arg#{&1}")
          |> Stream.map(&String.to_atom/1)
          |> Enum.map(&{&1, [], nil})

        {delegate_mod, delegate_macro} =
          case type do
            :functions -> {Kernel, :defdelegate}
            :macros -> {Delegator, :defdelegatemacro}
          end

        delegation =
          quote do
            unquote(delegate_mod).unquote(delegate_macro)(
              unquote(delegate_name)(unquote_splicing(args)),
              to: unquote(to),
              as: unquote(name)
            )
          end

        {{delegate_name, arity}, delegation}
      end

    {delegated, delegations} = Enum.unzip(result)

    overrides =
      if type === :functions do
        quote do: defoverridable(unquote(delegated))
      end

    delegations ++ [overrides]
  end

  @doc """
  Defines delegating functions for all functions in a module.

  See the ["Shared options"](#module-shared-options) section at the module
  documentation for more options.
  """
  defmacro defdelegateall(opts \\ []) do
    quote do: Delegator.__delegateall__(:functions, unquote(opts))
  end

  @doc """
  Defines delegating macros for all macros in a module.

  See the ["Shared options"](#module-shared-options) section at the module
  documentation for more options.
  """
  defmacro defdelegateallmacros(opts \\ []) do
    quote do: Delegator.__delegateall__(:macros, unquote(opts))
  end

  @doc """
  Define delegating functions and macros for everything in a module.

  See the ["Shared options"](#module-shared-options) section at the module
  documentation for more options.
  """
  defmacro defdelegateeverything(opts \\ []) do
    quote do
      defdelegateall unquote(opts)
      defdelegateallmacros unquote(opts)
    end
  end

  @doc """
  Defines a macro that delegates to another module.

  Similar to `defdelegate/2` but for macros.

  ## Options

  * `:to` - the module to dispatch to. Required.
  * `:as` - the macro to call on the target given in `:to`. Optional. Defaults
    to the name of the macro being delegated.
  """
  defmacro defdelegatemacro({name, _, args}, opts \\ []) do
    as = Keyword.get(opts, :as, name)

    to =
      with nil <- Keyword.get(opts, :to) do
        raise ArgumentError, ":to is required"
      end

    quote do
      defmacro unquote(name)(unquote_splicing(args)) do
        as = unquote(as)
        to = unquote(to)
        args = unquote(args)

        quote do
          require unquote(to)

          unquote(to).unquote(as)(unquote_splicing(args))
        end
      end
    end
  end

  @doc """
  Build a delegation name.

  Takes the original definition as a name-arity tuple. It then looks for any
  aliases matching that definition. If no alias is found, applies a prefix
  and/or suffix when provided.

  Prefix and suffix are not applied when an alias is provided, so the alias is
  honored as provided.

  When the definition name ends with `!` or `?`, the suffix is applied right
  before these characters.

  When the definition starts with `_`, no separator is placed after the prefix.
  When it ends with `_`, no separator is placed before the suffix.

  ## Examples

      iex> Delegator.delegate_name({:foo, 1}, Delegator.AliasesMap.new(bar: :foo), :pre, :post)
      "bar"

      iex> Delegator.delegate_name({:foo, 1}, Delegator.AliasesMap.new(%{{:bar, 1} => :foo}), :pre, :post)
      "bar"

      iex> Delegator.delegate_name({:foo, 1}, Delegator.AliasesMap.new(), :pre, :post)
      "pre_foo_post"

      iex> Delegator.delegate_name({:foo!, 1}, Delegator.AliasesMap.new(), :pre, :post)
      "pre_foo_post!"

      iex> Delegator.delegate_name({:__foo__, 1}, Delegator.AliasesMap.new(), :pre, :post)
      "pre__foo__post"
  """
  def delegate_name({name, arity}, aliases, prefix, suffix) do
    name = to_string(name)

    with nil <- AliasesMap.get(aliases, {name, arity}) do
      name |> prefix_def_name(prefix) |> suffix_def_name(suffix)
    end
  end

  defp prefix_def_name(name, prefix) do
    prefix = to_string(prefix)

    parts =
      cond do
        prefix == "" -> [name]
        String.starts_with?(name, "_") -> [prefix, name]
        true -> [prefix, "_", name]
      end

    Enum.join(parts)
  end

  defp suffix_def_name(name, suffix) do
    suffix = to_string(suffix)
    {rest, last} = String.split_at(name, -1)

    parts =
      cond do
        suffix == "" -> [name]
        last == "_" -> [name, suffix]
        last in ~w[! ?] -> [suffix_def_name(rest, suffix), last]
        true -> [name, "_", suffix]
      end

    Enum.join(parts)
  end
end
