defmodule Delegator.MixProject do
  use Mix.Project

  def project do
    [
      app: :delegator,
      version: "1.0.0-rc1",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      source_url: "https://codeberg.org/pfac/delegator",
      homepage_url: "https://codeberg.org/pfac/delegator",

      # Package metadata for Hex
      description: "Delegate functions and macros in bulk",
      package: package(),

      # Docs
      docs: docs()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application, do: []

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.0", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.40.0", only: :dev, runtime: false},
      {:styler, "~> 1.0", only: [:dev, :test], runtime: false}
    ]
  end

  defp docs do
    [
      extras: ["README.md", "CHANGELOG.md", "LICENSE.txt"],
      main: "readme"
    ]
  end

  defp package do
    [
      licenses: ["Apache-2.0"],
      links: %{"Codeberg" => "https://codeberg.org/pfac/delegator"},
      files: ~w[lib mix.exs README.md CHANGELOG.md LICENSE.txt]
    ]
  end
end
