defmodule TreeSitterHighlightTest do
  use ExUnit.Case
  doctest TreeSitterHighlight

  test "unsupported language" do
    assert {:error, :unsupported_language} = TreeSitterHighlight.render_html("123", :unknown)
  end

  test "write example files" do
    output_dir = "example_output/ex_tree_sitter_highlight"

    Enum.each(
      [
        {"test/fixtures/example_liveview.ex", "#{output_dir}/elixir_liveview.html"},
        {"native/treesitterhighlight/src/lib.rs", "#{output_dir}/rust.html"}
      ],
      fn {input, output} ->
        assert :ok ==
                 TreeSitterHighlight.write_highlighted_file(input, output)

        assert {:ok, content} = File.read(output)
        assert String.contains?(content, "</html>")
        assert String.contains?(content, "</style>")
        assert String.contains?(content, "</pre>")
        assert String.contains?(content, "</code>")
      end
    )

    assert {:error, :enoent} == TreeSitterHighlight.write_highlighted_file("file/not/found", "")
  end

  test "everything is ok" do
    TreeSitterHighlight.get_supported_languages()
    |> Enum.each(fn lang_atom
                    when is_atom(lang_atom) ->
      assert {:ok, html} = TreeSitterHighlight.render_html("\"foo\"", lang_atom)
      assert is_binary(html)
    end)
  end
end
