defmodule DelegatorTest do
  use ExUnit.Case

  defmodule Target do
    def a, do: 1
    def b(_), do: 2
    def c(_, _), do: 3
    def d(_, _, _), do: 4
  end

  defmodule Wrapper do
    use Delegator, to: DelegatorTest.Target
  end

  test "delegates all functions in target" do
    assert Wrapper.a() == 1
    assert Wrapper.b(1) == 2
    assert Wrapper.c(1, 2) == 3
    assert Wrapper.d(1, 2, 3) == 4
  end
end
