defmodule TreeSitterHighlightTest do
  use ExUnit.Case
  doctest TreeSitterHighlight

  test "everything is ok" do
    TreeSitterHighlight.get_supported_languages()
    |> Enum.each(fn lang_atom
                    when is_atom(lang_atom) ->
      assert {:ok, html} = TreeSitterHighlight.render_html("\"foo\"", lang_atom)
      assert is_binary(html)
    end)
  end

  test "unsupported language" do
    assert {:error, :unsupported_language} = TreeSitterHighlight.render_html("123", :unknown)
  end

  defp get_example_output_style do
    ~s"""
    <style>
    html {
       font-size: 13px;
    }
    html, body, pre {
       margin: 0;
    }
    pre {
        width: fit-content;
        min-width: 100vw;
    }
    .hidden-line-numbers .line-number {
      display: none;
    }
    .ui {
      display:flex;
      font-size: 14px;
      gap: 8px;
      padding: 8px;
    }
    #{TreeSitterHighlight.get_default_css_content()}
    </style>
    """
  end

  test "write example files" do
    # note: these output files are publically visible on github pages
    output_dir = "example_output/ex_tree_sitter_highlight"

    stylesheet = get_example_output_style()

    Enum.each(
      [
        {"test/fixtures/example_liveview.ex", "#{output_dir}/elixir_liveview.html"},
        {"native/treesitterhighlight/src/lib.rs", "#{output_dir}/rust.html"}
      ],
      fn {input, output} ->
        assert :ok ==
                 TreeSitterHighlight.write_highlighted_file(input, output, stylesheet)

        assert {:ok, content} = File.read(output)
        assert String.contains?(content, "</html>")
        assert String.contains?(content, "</style>")
        assert String.contains?(content, "</pre>")
        assert String.contains?(content, "</code>")
      end
    )

    assert {:error, :enoent} ==
             TreeSitterHighlight.write_highlighted_file("file/not/found", "", "")

    # write a file with some JS for toggling line nums/dark mode

    ui = ~s"""
    <div class="ui" >
      <label>Toggle dark<input type="checkbox" id="themeToggle"></label>
      <label>Hide line numbers<input type="checkbox" id="lineNumToggle"></label>
    </div>
    """

    script = ~s"""
    <script>
    themeToggle.addEventListener('change', () => {
      const h = document.querySelectorAll('html')[0];
      h.dataset.theme = !h.dataset.theme ? 'dark' : '';
    });

    lineNumToggle.addEventListener('change', () => {
      const code = document.querySelectorAll('code')[0];
      const cName = 'hidden-line-numbers'
      if (code.classList.contains(cName)) {
         code.classList.remove(cName);
      } else {
         code.classList.add(cName);
      }
    });
    </script>
    """

    {:ok, html_output} =
      ~s"""
      <!DOCTYPE html>
      <html>
      <body>
      #{ui}
      #{script}
      #{stylesheet}
      </body>
      </html>
      """
      |> TreeSitterHighlight.render_html(:html)

    File.write!(
      "#{output_dir}/dark_mode_and_line_toggle.html",
      ~s"""
      <!DOCTYPE html>
      <html>
      <body>
      #{stylesheet}
      #{ui}
      #{html_output}
      #{script}
      </body>
      </html>
      """
    )
  end

  # TODO: makeup as a test-only dep conflicts with hex docs dep.
  # test "write makeup output" do
  #   output_dir = "example_output/makeup"

  #   Enum.each(
  #     [
  #       # TODO: pull in more makeup dependencies and highlight other file types for comparison
  #       {"test/fixtures/example_liveview.ex", "#{output_dir}/elixir_liveview.html"}
  #     ],
  #     fn {input, output} ->
  #       {:ok, source} = File.read(input)
  #       highlighted_source = Makeup.highlight(source)
  #       stylesheet = Makeup.stylesheet()

  #       File.write!(output, ~s"""
  #         <!DOCTYPE html>
  #         <style>
  #         #{stylesheet}
  #         </style>
  #         <html>
  #         <body>
  #         #{highlighted_source}
  #         </body>
  #         </html>
  #       """)
  #     end
  #   )
  # end
end
