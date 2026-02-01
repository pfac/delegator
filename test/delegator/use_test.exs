defmodule Delegator.UseTest do
  use ExUnit.Case

  defmacrop refute_defined(mod, fun, arity) do
    quote do
      refute {unquote(fun), unquote(arity)} in unquote(mod).__info__(:functions)
    end
  end

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

  describe "delegate to a single module" do
    defmodule DelegateAllToOne do
      use Delegator, to: Delegator.UseTest.A
    end

    test "delegates all functions" do
      assert DelegateAllToOne.a() == 1
      assert DelegateAllToOne.a(1) == 2
      assert DelegateAllToOne.a(1, 2) == 3
      assert DelegateAllToOne.a(1, 2, 3) == 4
    end
  end

  describe "delegate to multiple modules" do
    defmodule DelegateAllToMany do
      use Delegator, to: [Delegator.UseTest.A, Delegator.UseTest.B]
    end

    test "delegates all functions" do
      assert DelegateAllToMany.a() == 1
      assert DelegateAllToMany.a(1) == 2
      assert DelegateAllToMany.a(1, 2) == 3
      assert DelegateAllToMany.a(1, 2, 3) == 4
      assert DelegateAllToMany.b() == 1
      assert DelegateAllToMany.b(1) == 2
      assert DelegateAllToMany.b(1, 2) == 3
      assert DelegateAllToMany.b(1, 2, 3) == 4
    end
  end

  describe "with only: nil" do
    defmodule DelegateWithNilOnly do
      use Delegator, to: [Delegator.UseTest.A, Delegator.UseTest.B], only: nil
    end

    test "delegates all functions" do
      assert DelegateWithNilOnly.a() == 1
      assert DelegateWithNilOnly.a(1) == 2
      assert DelegateWithNilOnly.a(1, 2) == 3
      assert DelegateWithNilOnly.a(1, 2, 3) == 4
      assert DelegateWithNilOnly.b() == 1
      assert DelegateWithNilOnly.b(1) == 2
      assert DelegateWithNilOnly.b(1, 2) == 3
      assert DelegateWithNilOnly.b(1, 2, 3) == 4
    end
  end

  describe "with only: [a: 0, b: 1]" do
    defmodule DelegateWithOnly do
      use Delegator, to: [Delegator.UseTest.A, Delegator.UseTest.B], only: [a: 0, b: 1]
    end

    test "delegates the functions listed in :only" do
      assert DelegateWithOnly.a() == 1
      assert DelegateWithOnly.b(1) == 2
    end

    test "does not delegate the functions not listed in :only" do
      refute_defined DelegateWithOnly, :a, 1
      refute_defined DelegateWithOnly, :a, 2
      refute_defined DelegateWithOnly, :a, 3
      refute_defined DelegateWithOnly, :b, 0
      refute_defined DelegateWithOnly, :b, 2
      refute_defined DelegateWithOnly, :b, 3
    end
  end

  describe "with only: []" do
    defmodule DelegateWithEmptyOnly do
      use Delegator, to: [Delegator.UseTest.A, Delegator.UseTest.B], only: []
    end

    test "does not delegate the any functions" do
      refute_defined DelegateWithEmptyOnly, :a, 0
      refute_defined DelegateWithEmptyOnly, :a, 1
      refute_defined DelegateWithEmptyOnly, :a, 2
      refute_defined DelegateWithEmptyOnly, :a, 3
      refute_defined DelegateWithEmptyOnly, :b, 0
      refute_defined DelegateWithEmptyOnly, :b, 1
      refute_defined DelegateWithEmptyOnly, :b, 2
      refute_defined DelegateWithEmptyOnly, :b, 3
    end
  end

  describe "with except: nil" do
    defmodule DelegateWithNilExcept do
      use Delegator, to: [Delegator.UseTest.A, Delegator.UseTest.B], except: nil
    end

    test "delegates all the functions" do
      assert DelegateWithNilExcept.a() == 1
      assert DelegateWithNilExcept.a(1) == 2
      assert DelegateWithNilExcept.a(1, 2) == 3
      assert DelegateWithNilExcept.a(1, 2, 3) == 4
      assert DelegateWithNilExcept.b() == 1
      assert DelegateWithNilExcept.b(1) == 2
      assert DelegateWithNilExcept.b(1, 2) == 3
      assert DelegateWithNilExcept.b(1, 2, 3) == 4
    end
  end

  describe "with except: [a: 0, b: 1]" do
    defmodule DelegateWithExcept do
      use Delegator, to: [Delegator.UseTest.A, Delegator.UseTest.B], except: [a: 0, b: 1]
    end

    test "delegates all the functions but the ones listed in :except" do
      assert DelegateWithExcept.a(1) == 2
      assert DelegateWithExcept.a(1, 2) == 3
      assert DelegateWithExcept.a(1, 2, 3) == 4
      assert DelegateWithExcept.b() == 1
      assert DelegateWithExcept.b(1, 2) == 3
      assert DelegateWithExcept.b(1, 2, 3) == 4
    end

    test "does not delegate the functions not listed in :except" do
      refute_defined DelegateWithExcept, :a, 0
      refute_defined DelegateWithExcept, :b, 1
    end
  end

  describe "with except: []" do
    defmodule DelegateWithEmptyExcept do
      use Delegator, to: [Delegator.UseTest.A, Delegator.UseTest.B], except: []
    end

    test "delegates all the functions" do
      assert DelegateWithEmptyExcept.a() == 1
      assert DelegateWithEmptyExcept.a(1) == 2
      assert DelegateWithEmptyExcept.a(1, 2) == 3
      assert DelegateWithEmptyExcept.a(1, 2, 3) == 4
      assert DelegateWithEmptyExcept.b() == 1
      assert DelegateWithEmptyExcept.b(1) == 2
      assert DelegateWithEmptyExcept.b(1, 2) == 3
      assert DelegateWithEmptyExcept.b(1, 2, 3) == 4
    end
  end

  describe "with prefix: nil" do
    defmodule DelegateWithNilPrefix do
      use Delegator, to: Delegator.UseTest.A, prefix: nil
    end

    test "delegates all functions without any prefix" do
      assert DelegateWithNilPrefix.a() == 1
      assert DelegateWithNilPrefix.a(1) == 2
      assert DelegateWithNilPrefix.a(1, 2) == 3
      assert DelegateWithNilPrefix.a(1, 2, 3) == 4
    end
  end

  describe "with prefix: :atom" do
    defmodule DelegateWithAtomPrefix do
      use Delegator, to: [Delegator.UseTest.A, Delegator.UseTest.B], prefix: :prefix
    end

    test "delegates all functions prefixed" do
      assert DelegateWithAtomPrefix.prefix_a() == 1
      assert DelegateWithAtomPrefix.prefix_a(1) == 2
      assert DelegateWithAtomPrefix.prefix_a(1, 2) == 3
      assert DelegateWithAtomPrefix.prefix_a(1, 2, 3) == 4
      assert DelegateWithAtomPrefix.prefix_b() == 1
      assert DelegateWithAtomPrefix.prefix_b(1) == 2
      assert DelegateWithAtomPrefix.prefix_b(1, 2) == 3
      assert DelegateWithAtomPrefix.prefix_b(1, 2, 3) == 4
    end
  end

  describe "with prefix: \"string\"" do
    defmodule DelegateWithStringPrefix do
      use Delegator, to: [Delegator.UseTest.A, Delegator.UseTest.B], prefix: "prefix"
    end

    test "delegates all functions prefixed" do
      assert DelegateWithStringPrefix.prefix_a() == 1
      assert DelegateWithStringPrefix.prefix_a(1) == 2
      assert DelegateWithStringPrefix.prefix_a(1, 2) == 3
      assert DelegateWithStringPrefix.prefix_a(1, 2, 3) == 4
      assert DelegateWithStringPrefix.prefix_b() == 1
      assert DelegateWithStringPrefix.prefix_b(1) == 2
      assert DelegateWithStringPrefix.prefix_b(1, 2) == 3
      assert DelegateWithStringPrefix.prefix_b(1, 2, 3) == 4
    end
  end

  describe "with prefix: \"\"" do
    defmodule DelegateWithBlankPrefix do
      use Delegator, to: Delegator.UseTest.A, prefix: ""
    end

    test "delegates all functions without any prefix" do
      assert DelegateWithBlankPrefix.a() == 1
      assert DelegateWithBlankPrefix.a(1) == 2
      assert DelegateWithBlankPrefix.a(1, 2) == 3
      assert DelegateWithBlankPrefix.a(1, 2, 3) == 4
    end
  end

  describe "with suffix: nil" do
    defmodule DelegateWithNilSuffix do
      use Delegator, to: Delegator.UseTest.A, suffix: nil
    end

    test "delegates all functions without any suffix" do
      assert DelegateWithNilSuffix.a() == 1
      assert DelegateWithNilSuffix.a(1) == 2
      assert DelegateWithNilSuffix.a(1, 2) == 3
      assert DelegateWithNilSuffix.a(1, 2, 3) == 4
    end
  end

  describe "with suffix: :atom" do
    defmodule DelegateWithAtomSuffix do
      use Delegator, to: [Delegator.UseTest.A, Delegator.UseTest.B], suffix: :suffix
    end

    test "delegates all functions suffixed" do
      assert DelegateWithAtomSuffix.a_suffix() == 1
      assert DelegateWithAtomSuffix.a_suffix(1) == 2
      assert DelegateWithAtomSuffix.a_suffix(1, 2) == 3
      assert DelegateWithAtomSuffix.a_suffix(1, 2, 3) == 4
      assert DelegateWithAtomSuffix.b_suffix() == 1
      assert DelegateWithAtomSuffix.b_suffix(1) == 2
      assert DelegateWithAtomSuffix.b_suffix(1, 2) == 3
      assert DelegateWithAtomSuffix.b_suffix(1, 2, 3) == 4
    end
  end

  describe "with suffix: \"string\"" do
    defmodule DelegateWithStringSuffix do
      use Delegator, to: [Delegator.UseTest.A, Delegator.UseTest.B], suffix: "suffix"
    end

    test "delegates all functions suffixed" do
      assert DelegateWithStringSuffix.a_suffix() == 1
      assert DelegateWithStringSuffix.a_suffix(1) == 2
      assert DelegateWithStringSuffix.a_suffix(1, 2) == 3
      assert DelegateWithStringSuffix.a_suffix(1, 2, 3) == 4
      assert DelegateWithStringSuffix.b_suffix() == 1
      assert DelegateWithStringSuffix.b_suffix(1) == 2
      assert DelegateWithStringSuffix.b_suffix(1, 2) == 3
      assert DelegateWithStringSuffix.b_suffix(1, 2, 3) == 4
    end
  end

  describe "with suffix: \"\"" do
    defmodule DelegateWithBlankSuffix do
      use Delegator, to: Delegator.UseTest.A, suffix: ""
    end

    test "delegates all functions without any suffix" do
      assert DelegateWithBlankSuffix.a() == 1
      assert DelegateWithBlankSuffix.a(1) == 2
      assert DelegateWithBlankSuffix.a(1, 2) == 3
      assert DelegateWithBlankSuffix.a(1, 2, 3) == 4
    end
  end

  describe "with as: nil" do
    defmodule DelegateWithNilAs do
      use Delegator, to: Delegator.UseTest.A, as: nil
    end

    test "delegates all functions without any aliases" do
      assert DelegateWithNilAs.a() == 1
      assert DelegateWithNilAs.a(1) == 2
      assert DelegateWithNilAs.a(1, 2) == 3
      assert DelegateWithNilAs.a(1, 2, 3) == 4
    end
  end

  describe "with as: []" do
    defmodule DelegateWithEmptyAs do
      use Delegator, to: Delegator.UseTest.A, as: []
    end

    test "delegates all functions without any aliases" do
      assert DelegateWithEmptyAs.a() == 1
      assert DelegateWithEmptyAs.a(1) == 2
      assert DelegateWithEmptyAs.a(1, 2) == 3
      assert DelegateWithEmptyAs.a(1, 2, 3) == 4
    end
  end

  describe "with as: [a: :c]" do
    defmodule DelegateWithKeywordAs do
      use Delegator, to: [Delegator.UseTest.A, Delegator.UseTest.B], as: [a: :c]
    end

    test "delegates all :a functions aliased as :c" do
      assert DelegateWithKeywordAs.c() == 1
      assert DelegateWithKeywordAs.c(1) == 2
      assert DelegateWithKeywordAs.c(1, 2) == 3
      assert DelegateWithKeywordAs.c(1, 2, 3) == 4
      assert DelegateWithKeywordAs.b() == 1
      assert DelegateWithKeywordAs.b(1) == 2
      assert DelegateWithKeywordAs.b(1, 2) == 3
      assert DelegateWithKeywordAs.b(1, 2, 3) == 4
    end
  end

  describe "with as: %{b: :c}" do
    defmodule DelegateWithSimpleMapAs do
      use Delegator, to: [Delegator.UseTest.A, Delegator.UseTest.B], as: %{b: :c}
    end

    test "delegates all :a functions aliased as :c" do
      assert DelegateWithSimpleMapAs.a() == 1
      assert DelegateWithSimpleMapAs.a(1) == 2
      assert DelegateWithSimpleMapAs.a(1, 2) == 3
      assert DelegateWithSimpleMapAs.a(1, 2, 3) == 4
      assert DelegateWithSimpleMapAs.c() == 1
      assert DelegateWithSimpleMapAs.c(1) == 2
      assert DelegateWithSimpleMapAs.c(1, 2) == 3
      assert DelegateWithSimpleMapAs.c(1, 2, 3) == 4
    end
  end

  describe "with as: %{{:a, 0} => :c}" do
    defmodule DelegateWithSpecificMapAs do
      use Delegator, to: [Delegator.UseTest.A, Delegator.UseTest.B], as: %{{:a, 0} => :c}
    end

    test "delegates all functions with a/0 aliased to c/0" do
      assert DelegateWithSpecificMapAs.c() == 1
      assert DelegateWithSpecificMapAs.a(1) == 2
      assert DelegateWithSpecificMapAs.a(1, 2) == 3
      assert DelegateWithSpecificMapAs.a(1, 2, 3) == 4
      assert DelegateWithSpecificMapAs.b() == 1
      assert DelegateWithSpecificMapAs.b(1) == 2
      assert DelegateWithSpecificMapAs.b(1, 2) == 3
      assert DelegateWithSpecificMapAs.b(1, 2, 3) == 4
    end
  end
end
