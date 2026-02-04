defmodule Delegator.MacrosTest do
  use Delegator.Test.Case

  defmodule A do
    def a, do: 1
    def a(_), do: 2
    def a(_, _), do: 3
    def a(_, _, _), do: 4

    defmacro m(x) do
      quote do: [unquote(x)]
    end

    defmacro m(x, y) do
      quote do: [unquote(x), unquote(y)]
    end

    defmacro m(x, y, z) do
      quote do: [unquote(x), unquote(y), unquote(z)]
    end
  end

  defmodule B do
    def b, do: 1
    def b(_), do: 2
    def b(_, _), do: 3
    def b(_, _, _), do: 4

    defmacro n(x) do
      quote do: [unquote(x)]
    end

    defmacro n(x, y) do
      quote do: [unquote(y), unquote(x)]
    end

    defmacro n(x, y, z) do
      quote do: [unquote(z), unquote(y), unquote(x)]
    end
  end

  describe "defdelegateall/1" do
    defmodule DefDelegateAll do
      import Delegator

      defdelegateall A
    end

    test "delegates all functions in A" do
      assert DefDelegateAll.a() == 1
      assert DefDelegateAll.a(1) == 2
      assert DefDelegateAll.a(1, 2) == 3
      assert DefDelegateAll.a(1, 2, 3) == 4
    end

    test "does not delegate any function in B" do
      refute_defined DefDelegateAll, :b
    end
  end

  describe "defdelegateall/2" do
    defmodule DefDelegateAllWithOpts do
      import Delegator

      defdelegateall A, as: [a: :c]
      defdelegateall A, except: [a: 0]
      defdelegateall B, only: [b: 0]
    end

    test "aliases all a/* functions in A as c/*" do
      require DefDelegateAllWithOpts
      assert DefDelegateAllWithOpts.c(1) == 2
      assert DefDelegateAllWithOpts.c(1, 2) == 3
      assert DefDelegateAllWithOpts.c(1, 2, 3) == 4
    end

    test "delegates all functions but a/0 in A" do
      refute_defined DefDelegateAllWithOpts, :a, 0
      assert DefDelegateAllWithOpts.a(1) == 2
      assert DefDelegateAllWithOpts.a(1, 2) == 3
      assert DefDelegateAllWithOpts.a(1, 2, 3) == 4
    end

    test "delegates only b/0 in B" do
      assert DefDelegateAllWithOpts.b() == 1
      refute_defined DefDelegateAllWithOpts, :b, 1
      refute_defined DefDelegateAllWithOpts, :b, 2
      refute_defined DefDelegateAllWithOpts, :b, 3
    end
  end

  describe "defdelegatemacro/2" do
    defmodule DefDelegateMacro do
      import Delegator

      defdelegatemacro m(x, y, z), to: A
      defdelegatemacro n(x, y, z), to: A, as: :m
    end

    test "delegates macro" do
      require DefDelegateMacro
      assert DefDelegateMacro.m(1, 2, 3) == [1, 2, 3]
    end

    test "delegates macro with another name" do
      require DefDelegateMacro
      assert DefDelegateMacro.n(1, 2, 3) == [1, 2, 3]
    end
  end

  describe "defdelegateallmacros/1" do
    defmodule DefDelegateAllMacros do
      import Delegator

      defdelegateallmacros A
    end

    test "delegates all macros in A" do
      require DefDelegateAllMacros
      assert DefDelegateAllMacros.m(1) == [1]
      assert DefDelegateAllMacros.m(1, 2) == [1, 2]
      assert DefDelegateAllMacros.m(1, 2, 3) == [1, 2, 3]
    end

    test "does not delegate any macros in B" do
      require DefDelegateAllMacros
      refute_macro DefDelegateAllMacros, :n
    end
  end

  describe "defdelegateallmacros/2" do
    defmodule DefDelegateAllMacrosWithOpts do
      import Delegator

      defdelegateallmacros A, as: [m: :o]
      defdelegateallmacros A, except: [m: 1]
      defdelegateallmacros B, only: [n: 1]
    end

    test "aliases all m/* macros in A as o/*" do
      require DefDelegateAllMacrosWithOpts
      assert DefDelegateAllMacrosWithOpts.o(1) == [1]
      assert DefDelegateAllMacrosWithOpts.o(1, 2) == [1, 2]
      assert DefDelegateAllMacrosWithOpts.o(1, 2, 3) == [1, 2, 3]
    end

    test "delegates all macros in A but m/1" do
      require DefDelegateAllMacrosWithOpts
      refute_macro DefDelegateAllMacrosWithOpts, :m, 1
      assert DefDelegateAllMacrosWithOpts.m(1, 2) == [1, 2]
      assert DefDelegateAllMacrosWithOpts.m(1, 2, 3) == [1, 2, 3]
    end

    test "delegates only macro n/1 in B" do
      require DefDelegateAllMacrosWithOpts
      assert DefDelegateAllMacrosWithOpts.n(1) == [1]
      refute_macro DefDelegateAllMacrosWithOpts, :n, 2
      refute_macro DefDelegateAllMacrosWithOpts, :n, 3
    end
  end

  describe "defdelegateeverything/1" do
    defmodule DefDelegateEverything do
      import Delegator

      defdelegateeverything A
    end

    test "delegates all functions in A" do
      assert DefDelegateEverything.a() == 1
      assert DefDelegateEverything.a(1) == 2
      assert DefDelegateEverything.a(1, 2) == 3
      assert DefDelegateEverything.a(1, 2, 3) == 4
    end

    test "does not delegate any function in B" do
      refute_defined DefDelegateEverything, :b
    end

    test "delegates all macros in A" do
      require DefDelegateEverything
      assert DefDelegateEverything.m(1) == [1]
      assert DefDelegateEverything.m(1, 2) == [1, 2]
      assert DefDelegateEverything.m(1, 2, 3) == [1, 2, 3]
    end

    test "does not delegate any macros in B" do
      require DefDelegateEverything
      refute_macro DefDelegateEverything, :n
    end
  end

  describe "defdelegateeverything/2" do
    defmodule DefDelegateEverythingWithOpts do
      import Delegator

      defdelegateeverything A, as: [a: :c, m: :o]
      defdelegateeverything A, except: [a: 0, m: 1]
      defdelegateeverything B, only: [b: 0, n: 1]
    end

    test "aliases all a/* functions in A as c/*" do
      require DefDelegateEverythingWithOpts
      assert DefDelegateEverythingWithOpts.c(1) == 2
      assert DefDelegateEverythingWithOpts.c(1, 2) == 3
      assert DefDelegateEverythingWithOpts.c(1, 2, 3) == 4
    end

    test "delegates all functions but a/0 in A" do
      refute_defined DefDelegateEverythingWithOpts, :a, 0
      assert DefDelegateEverythingWithOpts.a(1) == 2
      assert DefDelegateEverythingWithOpts.a(1, 2) == 3
      assert DefDelegateEverythingWithOpts.a(1, 2, 3) == 4
    end

    test "delegates only b/0 in B" do
      assert DefDelegateEverythingWithOpts.b() == 1
      refute_defined DefDelegateEverythingWithOpts, :b, 1
      refute_defined DefDelegateEverythingWithOpts, :b, 2
      refute_defined DefDelegateEverythingWithOpts, :b, 3
    end

    test "aliases all m/* macros in A as o/*" do
      require DefDelegateEverythingWithOpts
      assert DefDelegateEverythingWithOpts.o(1) == [1]
      assert DefDelegateEverythingWithOpts.o(1, 2) == [1, 2]
      assert DefDelegateEverythingWithOpts.o(1, 2, 3) == [1, 2, 3]
    end

    test "delegates all macros in A but m/1" do
      require DefDelegateEverythingWithOpts
      refute_macro DefDelegateEverythingWithOpts, :m, 1
      assert DefDelegateEverythingWithOpts.m(1, 2) == [1, 2]
      assert DefDelegateEverythingWithOpts.m(1, 2, 3) == [1, 2, 3]
    end

    test "delegates only macro n/1 in B" do
      require DefDelegateEverythingWithOpts
      assert DefDelegateEverythingWithOpts.n(1) == [1]
      refute_macro DefDelegateEverythingWithOpts, :n, 2
      refute_macro DefDelegateEverythingWithOpts, :n, 3
    end
  end
end
