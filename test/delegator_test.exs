defmodule DelegatorTest do
  use ExUnit.Case

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

  defmodule WrapAllOfOne do
    use Delegator, to: DelegatorTest.A
  end

  test "delegates all functions to a single module" do
    assert WrapAllOfOne.a() == 1
    assert WrapAllOfOne.a(1) == 2
    assert WrapAllOfOne.a(1, 2) == 3
    assert WrapAllOfOne.a(1, 2, 3) == 4
  end

  defmodule WrapAllOfMany do
    use Delegator, to: [DelegatorTest.A, DelegatorTest.B]
  end

  test "delegates all functions to multiple modules" do
    assert WrapAllOfMany.a() == 1
    assert WrapAllOfMany.a(1) == 2
    assert WrapAllOfMany.a(1, 2) == 3
    assert WrapAllOfMany.a(1, 2, 3) == 4
    assert WrapAllOfMany.b() == 1
    assert WrapAllOfMany.b(1) == 2
    assert WrapAllOfMany.b(1, 2) == 3
    assert WrapAllOfMany.b(1, 2, 3) == 4
  end

  defmodule WrapOnlyOfOne do
    use Delegator, to: DelegatorTest.A, only: [a: 0]
  end

  test "delegates the functions listed in :only to a single module" do
    assert WrapOnlyOfOne.a() == 1
  end

  test "does not delegate the functions not listed in :only to a single module" do
    assert_raise UndefinedFunctionError, fn -> WrapOnlyOfOne.a(1) end
  end

  defmodule WrapOnlyOfMany do
    use Delegator, to: [DelegatorTest.A, DelegatorTest.B], only: [a: 0, b: 1]
  end

  test "delegates the functions listed in :only to multiple modules" do
    assert WrapOnlyOfMany.a() == 1
    assert WrapOnlyOfMany.b(1) == 2
  end

  test "does not delegate the functions not listed in :only to multiple modules" do
    assert_raise UndefinedFunctionError, fn -> WrapOnlyOfMany.a(1) end
    assert_raise UndefinedFunctionError, fn -> WrapOnlyOfMany.b() end
  end
end
