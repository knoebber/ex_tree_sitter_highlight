defmodule ExTreeSitterHighlight.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_tree_sitter_highlight,
      deps: deps(),
      description:
        "Renders source code into highlighted html via a NIF binding to the rust tree-sitter-highlight crate",
      elixir: "~> 1.15",
      name: "Elixir Tree Sitter Highlight",
      package: package(),
      source_url: "https://github.com/knoebber/ex_tree_sitter_highlight",
      start_permanent: Mix.env() == :prod,
      version: "0.1.0"
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

  defp package() do
    [
      files: [
        "lib",
        "priv",
        ".formatter.exs",
        "mix.exs",
        "README.md",
        "LICENSE",
        "src",
        "native/treesitterhighlight/.cargo",
        "native/treesitterhighlight/src",
        "native/treesitterhighlight/cargo.lock",
        "native/treesitterhighlight/cargo.toml",
        "native/treesitterhighlight/README.md"
      ],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/knoebber/ex_tree_sitter_highlight"}
    ]
  end
end
