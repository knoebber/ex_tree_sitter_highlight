defmodule TreeSitterHighlight do
  @moduledoc """
    Elixir binding for https://docs.rs/tree-sitter-highlight/latest/tree_sitter_highlight/
  """
  use Rustler, otp_app: :ex_tree_sitter_highlight, crate: "treesitterhighlight"

  # When your NIF is loaded, it will override this function.
  def render_html(_source_code, _language_atom), do: :erlang.nif_error(:nif_not_loaded)

  def language_from_filename(path) do
    case Path.extname(path) do
      ".ex" -> :elixir
      ".exs" -> :elixir
      ".html" -> :html
      ".js" -> :javascript
      ".rs" -> :rust
      ".css" -> :css
      _ -> :unknown
    end
  end

  def highlight_file(input_path, output_path, stylesheet \\ "priv/default.css")
      when is_binary(input_path) and is_binary(output_path) do
    with {:ok, source_code} <- File.read(input_path),
         {:ok, css_theme} <- File.read(stylesheet),
         {:ok, html} <- __MODULE__.render_html(source_code, language_from_filename(input_path)),
         :ok <-
           File.write(output_path, ~s"""
             <!DOCTYPE html>
             <style>
             #{css_theme}
             </style>
             <html lang="en">
             <body>
             #{html}
             </body>
             </html>
           """) do
      :ok
    end
  end
end
