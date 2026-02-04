defmodule DelegatorTest do
  use Delegator.Test.Case

  defmodule A do
    @moduledoc false
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
    @moduledoc false
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
      @moduledoc false
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

    defmodule DelegatedFunctionsAreOverridable do
      @moduledoc false
      use Delegator, to: A

      def a(_, _, _), do: 5
    end

    test "delegated functions are overridable" do
      assert DelegatedFunctionsAreOverridable.a(1, 2, 3) == 5
    end
  end

  describe "defdelegateall/2" do
    defmodule DefDelegateAllWithOpts do
      @moduledoc false
      import Delegator

      defdelegateall A, as: [a: :c]
      defdelegateall A, except: [a: 0]
      defdelegateall B, only: [b: 0]
      defdelegateall B, prefix: :before
      defdelegateall B, suffix: :after
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

    test "delegates all functions in B prefixed" do
      assert DefDelegateAllWithOpts.before_b()
      assert DefDelegateAllWithOpts.before_b(1) == 2
      assert DefDelegateAllWithOpts.before_b(1, 2) == 3
      assert DefDelegateAllWithOpts.before_b(1, 2, 3) == 4
    end

    test "delegates all functions in B suffixed" do
      assert DefDelegateAllWithOpts.b_after()
      assert DefDelegateAllWithOpts.b_after(1) == 2
      assert DefDelegateAllWithOpts.b_after(1, 2) == 3
      assert DefDelegateAllWithOpts.b_after(1, 2, 3) == 4
    end
  end

  describe "defdelegatemacro/2" do
    defmodule DefDelegateMacro do
      @moduledoc false
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
      @moduledoc false
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
      @moduledoc false
      import Delegator

      defdelegateallmacros A, as: [m: :o]
      defdelegateallmacros A, except: [m: 1]
      defdelegateallmacros B, only: [n: 1]
      defdelegateallmacros B, prefix: :before
      defdelegateallmacros B, suffix: :after
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

    test "delegates all macros in B prefixed" do
      require DefDelegateAllMacrosWithOpts

      assert DefDelegateAllMacrosWithOpts.before_n(1) == [1]
      assert DefDelegateAllMacrosWithOpts.before_n(1, 2) == [2, 1]
      assert DefDelegateAllMacrosWithOpts.before_n(1, 2, 3) == [3, 2, 1]
    end

    test "delegates all macros in B suffixed" do
      require DefDelegateAllMacrosWithOpts

      assert DefDelegateAllMacrosWithOpts.n_after(1) == [1]
      assert DefDelegateAllMacrosWithOpts.n_after(1, 2) == [2, 1]
      assert DefDelegateAllMacrosWithOpts.n_after(1, 2, 3) == [3, 2, 1]
    end
  end

  describe "defdelegateeverything/1" do
    defmodule DefDelegateEverything do
      @moduledoc false
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
      @moduledoc false
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

  describe "use Delegator to a single module" do
    defmodule DelegateEverythingToOne do
      @moduledoc false
      use Delegator, to: A
    end

    test "delegates all functions in A" do
      assert DelegateEverythingToOne.a() == 1
      assert DelegateEverythingToOne.a(1) == 2
      assert DelegateEverythingToOne.a(1, 2) == 3
      assert DelegateEverythingToOne.a(1, 2, 3) == 4
    end

    test "delegates all macros in A" do
      require DelegateEverythingToOne

      assert DelegateEverythingToOne.m(1) == [1]
      assert DelegateEverythingToOne.m(1, 2) == [1, 2]
      assert DelegateEverythingToOne.m(1, 2, 3) == [1, 2, 3]
    end
  end

  describe "use Delegator to multiple modules" do
    defmodule DelegateEverythingToMany do
      @moduledoc false
      use Delegator, to: [A, B]
    end

    test "delegates all functions" do
      assert DelegateEverythingToMany.a() == 1
      assert DelegateEverythingToMany.a(1) == 2
      assert DelegateEverythingToMany.a(1, 2) == 3
      assert DelegateEverythingToMany.a(1, 2, 3) == 4
      assert DelegateEverythingToMany.b() == 1
      assert DelegateEverythingToMany.b(1) == 2
      assert DelegateEverythingToMany.b(1, 2) == 3
      assert DelegateEverythingToMany.b(1, 2, 3) == 4
    end

    test "delegates all macros" do
      require DelegateEverythingToMany

      assert DelegateEverythingToMany.m(1) == [1]
      assert DelegateEverythingToMany.m(1, 2) == [1, 2]
      assert DelegateEverythingToMany.m(1, 2, 3) == [1, 2, 3]
      assert DelegateEverythingToMany.n(1) == [1]
      assert DelegateEverythingToMany.n(1, 2) == [2, 1]
      assert DelegateEverythingToMany.n(1, 2, 3) == [3, 2, 1]
    end
  end
end
