defmodule TreeSitterHighlight do
  @moduledoc """
    Elixir bindings for https://docs.rs/tree-sitter-highlight/latest/tree_sitter_highlight/
  """
  use Rustler, otp_app: :ex_tree_sitter_highlight, crate: "treesitterhighlight"

  # When your NIF is loaded, it will override this function.
  def highlight_code(_a), do: :erlang.nif_error(:nif_not_loaded)
end
