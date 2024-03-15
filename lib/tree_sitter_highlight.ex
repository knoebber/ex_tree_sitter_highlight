defmodule TreeSitterHighlight do
  @moduledoc """
    Elixir binding for https://docs.rs/tree-sitter-highlight/latest/tree_sitter_highlight/
  """
  use Rustler, otp_app: :ex_tree_sitter_highlight, crate: "treesitterhighlight"

  def render_html(_source_code, _language_atom), do: :erlang.nif_error(:nif_not_loaded)
  def get_supported_languages(), do: :erlang.nif_error(:nif_not_loaded)
  def get_language_from_filename(_filename), do: :erlang.nif_error(:nif_not_loaded)

  def highlight_file(input_path, output_path, stylesheet \\ "priv/default.css")
      when is_binary(input_path) and is_binary(output_path) do
    with {:ok, source_code} <- File.read(input_path),
         {:ok, css_theme} <- File.read(stylesheet),
         {:ok, html} <-
           __MODULE__.render_html(source_code, get_language_from_filename(input_path)),
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
