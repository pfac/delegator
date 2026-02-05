defmodule Delegator.MixProject do
  use Mix.Project

  def project do
    [
      app: :delegator,
      version: "0.1.0",
      elixir: "~> 1.19",
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # Docs
      docs: &docs/0
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.0", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.0", only: :dev},
      {:styler, "~> 1.0", only: [:dev, :test], runtime: false}
    ]
  end

  defp docs do
    []
  end
end
