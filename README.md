# Delegator

[![build](https://github.com/pfac/delegator/actions/workflows/build.yml/badge.svg)](https://github.com/pfac/delegator/actions/workflows/build.yml)

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
    {:delegator, "0.2.0"}
  ]
end
```

Then run `mix deps.get`.

## Usage

Use `Delegator`'s macros to delegate a module's functions and macros.

```elixir
defmodule MyModule do
  import Delegator
  
  # Delegate a single macro
  defdelegatemacro m(x, y, z), to: TargetModule
  
  # Delegate all functions/macros
  defdelegateall to: FunctionsModule
  defdelegateallmacros to: MacrosModule
  
  # Delegate everything (similar to use Delegator with a single module)
  defdelegateeverything to: SuperModule
end
```

See the [shared options] documentation for more ways to customise these
delegations.

[shared options]: https://hexdocs.pm/delegator/Delegator.html#module-shared-options

## Acknowledgements

Inspired by [delegate](https://github.com/rill-project/delegate).

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
