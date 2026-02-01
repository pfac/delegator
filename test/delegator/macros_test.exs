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
end
