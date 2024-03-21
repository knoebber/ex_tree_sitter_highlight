# Elixir Tree Sitter Highlight

Elixir nif binding for the rust crate
[tree_sitter_higlight](https://docs.rs/tree-sitter-highlight/latest/tree_sitter_highlight/).

## Installation

Hex: https://hexdocs.pm/ex_tree_sitter_highlight/TreeSitterHighlight.html

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
