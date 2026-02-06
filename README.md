# Delegator

Delegate functions and macros in bulk.

Delegator extends Elixir's built-in delegation mechanism with powerful options
for delegating multiple functions and macros at once, with flexible naming and
filtering options.

## Features

- **Macro Delegation** - Delegate macros just like functions
- **Bulk Delegation** - Delegate all functions and/or macros at once
- **Multiple Module Support** - Delegate to multiple modules simultaneously
- **Fine-Grained Filtering** - Include/exclude specific definitions
- **Flexible Naming** - Rename, prefix, or suffix delegated items
- **Overridable Functions** - Mass delegated functions are overridable

## Installation

Add Delegator to your `mix.exs` dependencies:

```elixir
def deps do
  [
    {:delegator, "1.0.0-rc1"}
  ]
end
```

Then run `mix deps.get`.

## Usage

The simplest way to delegate everything from some modules is to `use` Decorator:

```elixir
defmodule MyModule do
  use Delegator, to: A
  use Delegator, to: [B, C]
end
```

This creates delegations in `MyModule` for all functions and macros defined by
`TargetModule`.

### More flexibility

If you need more flexibility, such as only delegate a module's functions but
not its macros, you can instead:

```elixir
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
  use Delegator, to: A
  use Delegator, to: [B, C]
end
```

See the shared options documentation for more ways to customise these
delegations.

## License

Copyright 2026 Pedro Costa

Licensed under the Apache License, Version 2.0 (the "License"); you may not use
this file except in compliance with the License. You may obtain a copy of the
License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed
under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
CONDITIONS OF ANY KIND, either express or implied. See the License for the
specific language governing permissions and limitations under the License.
