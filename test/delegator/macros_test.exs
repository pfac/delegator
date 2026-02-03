defmodule Delegator.MacrosTest do
  use Delegator.Test.Case

  defmodule A do
    def a, do: 1
    def a(_), do: 2
    def a(_, _), do: 3
    def a(_, _, _), do: 4
  end

  defmodule B do
    def b, do: 1
    def b(_), do: 2
    def b(_, _), do: 3
    def b(_, _, _), do: 4
  end

  defmodule M do
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

  defmodule N do
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
    defmodule DefDelegateAllWithoutOpts do
      import Delegator

      defdelegateall A
    end

    test "delegates all functions in A" do
      assert DefDelegateAllWithoutOpts.a() == 1
      assert DefDelegateAllWithoutOpts.a(1) == 2
      assert DefDelegateAllWithoutOpts.a(1, 2) == 3
      assert DefDelegateAllWithoutOpts.a(1, 2, 3) == 4
    end

    test "does not delegate any function in B" do
      refute_defined DefDelegateAllWithoutOpts, :b
    end
  end

  describe "defdelegateall/2" do
    defmodule DefDelegateAllWithOpts do
      import Delegator

      defdelegateall A, except: [a: 0]
      defdelegateall B, only: [b: 0]
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

      defdelegatemacro m(x, y, z), to: M
      defdelegatemacro n(x, y, z), to: M, as: :m
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
    defmodule DefDelegateAllMacrosWithoutOpts do
      import Delegator

      defdelegateallmacros M
    end

    test "delegates all macros in M" do
      require DefDelegateAllMacrosWithoutOpts
      assert DefDelegateAllMacrosWithoutOpts.m(1) == [1]
      assert DefDelegateAllMacrosWithoutOpts.m(1, 2) == [1, 2]
      assert DefDelegateAllMacrosWithoutOpts.m(1, 2, 3) == [1, 2, 3]
    end

    test "does not delegate any macros in N" do
      require DefDelegateAllMacrosWithoutOpts
      refute_macro DefDelegateAllMacrosWithoutOpts, :n
    end
  end

  describe "defdelegateallmacros/2" do
    defmodule DefDelegateAllMacrosWithOpts do
      import Delegator

      defdelegateallmacros M, as: [m: :o]
      defdelegateallmacros M, except: [m: 1]
      defdelegateallmacros N, only: [n: 1]
    end

    test "aliases all m/* macros in M as o/*" do
      require DefDelegateAllMacrosWithOpts
      assert DefDelegateAllMacrosWithOpts.o(1) == [1]
      assert DefDelegateAllMacrosWithOpts.o(1, 2) == [1, 2]
      assert DefDelegateAllMacrosWithOpts.o(1, 2, 3) == [1, 2, 3]
    end

    test "delegates all macros in M but m/1" do
      require DefDelegateAllMacrosWithOpts
      refute_macro DefDelegateAllMacrosWithOpts, :m, 1
      assert DefDelegateAllMacrosWithOpts.m(1, 2) == [1, 2]
      assert DefDelegateAllMacrosWithOpts.m(1, 2, 3) == [1, 2, 3]
    end

    test "delegates only macro n/1 in N" do
      require DefDelegateAllMacrosWithOpts
      assert DefDelegateAllMacrosWithOpts.n(1) == [1]
      refute_macro DefDelegateAllMacrosWithOpts, :n, 2
      refute_macro DefDelegateAllMacrosWithOpts, :n, 3
    end
  end
end
