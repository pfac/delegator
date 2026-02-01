defmodule Delegator.Opts do
  @moduledoc """
  Shared options module for a consistent handling in Delegator.
  """

  def aliases(opts) do
    entries =
      case opts[:as] do
        nil -> []
        {:%{}, _, kw} -> kw
        kw -> kw
      end

    Map.new(entries, fn
      {{fun_name, fun_arity}, fun_alias} -> {{"#{fun_name}", fun_arity}, "#{fun_alias}"}
      {fun_name, fun_alias} -> {"#{fun_name}", "#{fun_alias}"}
    end)
  end

  def except(opts) do
    case Keyword.get(opts, :except) do
      nil -> nil
      funs -> MapSet.new(funs)
    end
  end

  def only(opts) do
    case Keyword.get(opts, :only) do
      nil -> nil
      funs -> MapSet.new(funs)
    end
  end

  def prefix(opts), do: Keyword.get(opts, :prefix)
  def suffix(opts), do: Keyword.get(opts, :suffix)
end
