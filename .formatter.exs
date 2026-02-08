locals_without_parens = [
  defdelegateall: 1,
  defdelegateall: 2,
  defdelegateallmacros: 1,
  defdelegateallmacros: 2,
  defdelegateeverything: 1,
  defdelegateeverything: 2,
  defdelegatemacro: 2,
  refute_defined: 2,
  refute_defined: 3,
  refute_macro: 2,
  refute_macro: 3
]

[
  export: [
    locals_without_parens: locals_without_parens
  ],
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"],
  locals_without_parens: locals_without_parens,
  plugins: [Styler]
]
