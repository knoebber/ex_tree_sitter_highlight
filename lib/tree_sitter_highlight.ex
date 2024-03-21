defmodule TreeSitterHighlight do
  @moduledoc """
    Elixir binding for https://docs.rs/tree-sitter-highlight/latest/tree_sitter_highlight/
  """
  use Rustler, otp_app: :ex_tree_sitter_highlight, crate: "treesitterhighlight"

  @doc ~S"""
  Renders the given source code into html.

  ## Examples

      iex> TreeSitterHighlight.render_html("1", :elixir)
      {:ok, "<pre class=\"code-block language-elixir\"><code>\n<div class=\"line-wrapper\"><span class=\"line-number\">1</span><span class=\"token number\">1</span>\n</div>\n</code></pre>\n"}

      iex> TreeSitterHighlight.render_html("1", :txt)
      {:error, :unsupported_language}
  """
  def render_html(_source_code, _language_atom), do: :erlang.nif_error(:nif_not_loaded)

  @doc ~S"""
  Returns a list of supported language atoms.
  """
  def get_supported_languages(), do: :erlang.nif_error(:nif_not_loaded)

  @doc ~S"""
  Returns a language atom for the file, or nil if the language isn't supported.

  ## Examples

      iex> TreeSitterHighlight.get_language_from_filename("/path/file.ex")
      :elixir

      iex> TreeSitterHighlight.get_language_from_filename("/path/file.txt")
      nil
  """
  def get_language_from_filename(_filename), do: :erlang.nif_error(:nif_not_loaded)

  @doc ~S"""
  Returns CSS content with classes for highlighting and formatting html output.
  See priv/default.css for an example of how to create your own stylesheet.
  This stylesheet contains both a light and dark color scheme.
  To toggle the dark scheme set data-theme="dark" on the root <html> element.
  """
  def get_default_css_content() do
    File.read!("priv/default.css")
  end

  @doc ~S"""
  Writes a complete html document with highlighted code within.
  head_content should contain a stylesheet.

  ## Example

      iex> TreeSitterHighlight.write_highlighted_file(
      ...> "lib/tree_sitter_highlight.ex",
      ...> "example_output/ex_tree_sitter_highlight/tree_sitter_highlight.html",
      ...> "<style>#{TreeSitterHighlight.get_default_css_content()}</style>"
      ...> )
      :ok
  """
  def write_highlighted_file(input_path, output_path, head_content)
      when is_binary(input_path) and is_binary(output_path) and is_binary(head_content) do
    with {:ok, source_code} <- File.read(input_path),
         {:ok, html} <-
           __MODULE__.render_html(source_code, get_language_from_filename(input_path)),
         :ok <-
           File.write(output_path, ~s"""
             <!DOCTYPE html>
             <html>
             <head>
             #{head_content}
             </head>
             <body>
             #{html}
             </body>
             </html>
           """) do
      :ok
    end
  end
end
