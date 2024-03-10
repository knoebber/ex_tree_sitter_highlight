defmodule TreeSitterHighlightTest do
  use ExUnit.Case

  defp strip_space(s), do: s |> String.replace("\n", "") |> String.replace(" ", "")

  defp html_equal(expected, actual) do
    assert strip_space(actual) == strip_space(expected)
  end

  test "unsupported language" do
    assert {:error, :unsupported_language} = TreeSitterHighlight.render_html("123", :unknown)
  end

  test "highlights elixir" do
    assert {:ok, html} =
             TreeSitterHighlight.render_html(
               ~S"""
               test "highlights elixir" do
                  assert {:ok, html} = TreeSitterHighlight.render_html("", :elixir)
               end
               """,
               :elixir
             )

    assert html_equal(
             ~S"""
             <pre class="code-block">
             <code>
             <div class="line-wrapper">
             <span class="line-number">1</span>
             <span class="function">test</span><span class="string">&quot;highlights elixir&quot;</span> <span class="keyword">do</span>
             </div>
             <div class="line-wrapper">
             <span class="line-number">2</span>
             <span class="function">assert</span>
             <span class="punctuation-bracket">{</span>
             <span class="string-special">:ok</span>
             <span class="punctuation-delimiter">,</span>
             html<span class="punctuation-bracket">}</span>
             <span class="operator">=</span>
             <span class="module">TreeSitterHighlight</span>
             <span class="operator">.</span>
             <span class="function">
             render_html</span>
             <span class="punctuation-bracket">(</span><span class="string">&quot;&quot;
             </span><span class="punctuation-delimiter">,</span>
             <span class="string-special">:elixir</span>
             <span class="punctuation-bracket">)</span>
             </div>
             <div class="line-wrapper"><span class="line-number">3</span><span class="keyword">end</span></div>
             </code>
             </pre>
             """,
             html
           )
  end

  test "highlights javascript" do
    assert {:ok, html} = TreeSitterHighlight.render_html("const y = 2;", :javascript)

    assert html_equal(
             ~S"""
             <pre class="code-block">
             <code>
             <div class="line-wrapper">
             <span class="line-number">1</span>
             <span class="keyword">const</span> y <span class="operator">=</span> <span class="number">2</span>
             <span class="punctuation-delimiter">;</span></div>
             </code>
             </pre>
             """,
             html
           )
  end
end
