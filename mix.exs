defmodule ExTreeSitterHighlight.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_tree_sitter_highlight,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps()
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
      {:rustler, "~> 0.31.0", runtime: false},
      {:makeup, "~> 1.1.1", only: [:test]},
      {:makeup_elixir, "~> 0.14.0", only: [:test]}
    ]
  end
end
