# Wrapper

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `wrapper` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:wrapper, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/wrapper>.

## Usage

The simplest way to delegate all functions and macros from a module is to use
the `use` macro:

    defmodule MyModule do
      use Delegator, to: ModuleA
      use Delegator, to: [ModuleB, ModuleC]
    end

This will create delegations in `MyModule` for all functions and macros defined
in `TargetModule`.

### More flexibility

If you need more flexibility, such as only delegate a module's functions but not
its macros, you can instead use `Delegator`'s macros and call only what you
need:

    defmodule MyModule do
      import Delegator
      
      # Delegate a single macro
      defdelegatemacro m(x, y, z), to: TargetModule
      
      # Delegate all functions/macros
      defdelegateall FunctionsModule
      defdelegateallmacros MacrosModule
      
      # Delegate everything (similar to use Delegator with a single module)
      defdelegateeverything SuperModule
      
      # Delegate everything, to one or multiple modules
      use Delegator, to: ModuleA
      use Delegator, to: [ModuleB, ModuleC]
    end
    
See the shared options documentation for more ways to customise these
delegations.
