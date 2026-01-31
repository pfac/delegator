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
end
