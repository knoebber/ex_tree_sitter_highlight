use rustler::NifUnitEnum;
use std::fmt::Write;
use tree_sitter_highlight::HighlightConfiguration;
use tree_sitter_highlight::Highlighter;
use tree_sitter_highlight::HtmlRenderer;

mod atoms {
    rustler::atoms! {
        ok,
        error,
    }
}

#[derive(NifUnitEnum)]
pub enum Language {
    Elixir,
    Javascript,
    Rust,
}

const HIGHLIGHT_NAMES: [&str; 18] = [
    "attribute",
    "constant",
    "function.builtin",
    "function",
    "keyword",
    "operator",
    "property",
    "punctuation",
    "punctuation.bracket",
    "punctuation.delimiter",
    "string",
    "string.special",
    "tag",
    "type",
    "type.builtin",
    "variable",
    "variable.builtin",
    "variable.parameter",
];

fn get_config() -> HighlightConfiguration {
    let javascript_language = tree_sitter_javascript::language();
    let mut javascript_config = HighlightConfiguration::new(
        javascript_language,
        tree_sitter_javascript::HIGHLIGHT_QUERY,
        tree_sitter_javascript::INJECTION_QUERY,
        tree_sitter_javascript::LOCALS_QUERY,
    )
    .unwrap();
    javascript_config.configure(&HIGHLIGHT_NAMES);
    javascript_config
}

#[rustler::nif]
fn render_html(source_code: &str) -> String {
    let html_attrs: [String; 18] =
        HIGHLIGHT_NAMES.map(|s| format!(r#"class="{}""#, s.replace(".", "-")));

    let mut highlighter = Highlighter::new();
    let highlight_config = get_config();
    let source_code_bytes = source_code.as_bytes();
    let events = highlighter
        .highlight(&highlight_config, source_code_bytes, None, |_| None)
        .unwrap();
    let mut renderer = HtmlRenderer::new();

    renderer
        .render(events, source_code_bytes, &|highlight| {
            html_attrs[highlight.0].as_bytes()
        })
        .unwrap();

    let mut html = String::new();
    for (i, line) in renderer.lines().enumerate() {
        writeln!(
            html,
            r#"<div class="line-wrapper"><span class="line-number">{}</span>{}</div>"#,
            i + 1,
            line,
        )
        .unwrap();
    }

    html
}

rustler::init!("Elixir.TreeSitterHighlight", [render_html]);
