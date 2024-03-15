defmodule TreeSitterHighlightTest do
  use ExUnit.Case

  test "unsupported language" do
    assert {:error, :unsupported_language} = TreeSitterHighlight.render_html("123", :unknown)
  end

  test "highlights elixir" do
    assert {:ok, html} = TreeSitterHighlight.render_html("def foo(bar), do: 3", :elixir)

    assert "<pre class=\"code-block language-elixir\"><code>\n<div class=\"line-wrapper\"><span class=\"line-number\">1</span><span class=\"token keyword\">def</span> <span class=\"token function\">foo</span><span class=\"token punctuation bracket\">(</span>bar<span class=\"token punctuation bracket\">)</span><span class=\"token punctuation delimiter\">,</span> <span class=\"token string special\">do: </span><span class=\"token number\">3</span>\n</div>\n</code></pre>\n" ==
             html
  end

  test "highlights heex" do
    assert {:ok, html} = TreeSitterHighlight.render_html("<.card :if={@foo == bar}>", :heex)

    assert "<pre class=\"code-block language-heex\"><code>\n<div class=\"line-wrapper\"><span class=\"line-number\">1</span><span class=\"token punctuation bracket\">&lt;</span><span class=\"token punctuation delimiter\">.</span><span class=\"token function\">card</span> <span class=\"token keyword\">:if</span><span class=\"token operator\">=</span><span class=\"token punctuation bracket\">{</span><span class=\"token attribute\">@</span><span class=\"token attribute\">foo</span> <span class=\"token operator\">==</span> bar<span class=\"token punctuation bracket\">}</span><span class=\"token punctuation bracket\">&gt;</span>\n</div>\n</code></pre>\n" ==
             html
  end
end
