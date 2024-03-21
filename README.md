# Elixir Tree Sitter Highlight

[![Module Version](https://img.shields.io/hexpm/v/makeup.svg)](https://hex.pm/packages/ex_tree_sitter_highlight)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/ex_tree_sitter_highlight/TreeSitterHighlight.html)

Tree Sitter Highlight uses
[treesitter](https://tree-sitter.github.io/tree-sitter/)
to transform source code into highlighted HTML.

This is implemented with a nif binding to the rust crate
[tree_sitter_higlight](https://docs.rs/tree-sitter-highlight/latest/tree_sitter_highlight/).

## Why not [makeup](https://github.com/elixir-makeup/makeup)?

The main advantage is that adding language support is much easier since many
tree sitter grammars have already been written. Tree sitter can also handle language injections, e.g. it can highlight heex code inside of an elixir string.

## Installation

The package can be installed by adding `ex_tree_sitter_highlight` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_tree_sitter_highlight, "~> 0.2.0"}
  ]
end
```

## Usage

**Supported languages:**

```elixir
iex(1)> TreeSitterHighlight.get_supported_languages
[:c, :css, :elixir, :go, :haskell, :heex, :html, :javascript, :json, :rust]
```

**Render html:**

```elixir
iex(2)> TreeSitterHighlight.render_html("1", :elixir)
{:ok,
 "<pre class=\"code-block language-elixir\"><code>\n<div class=\"line-wrapper\"><span class=\"line-number\">1</span><span class=\"token number\">1</span>\n</div>\n</code></pre>\n"}
```

**Get the default stylesheet:**

```elixir
iex(3)> TreeSitterHighlight.get_default_css_content()
# returns content of priv/default.css
```

## Example Output

### Side by side comparison with Elixir Makeup:

https://knoebber.github.io/ex_tree_sitter_highlight/comparison.html

### Simple UI for toggling dark mode / line numbers

https://knoebber.github.io/ex_tree_sitter_highlight/example_output/ex_tree_sitter_highlight/dark_mode_and_line_toggle.html

### This project's rust source code:

https://knoebber.github.io/ex_tree_sitter_highlight/example_output/ex_tree_sitter_highlight/rust.html
