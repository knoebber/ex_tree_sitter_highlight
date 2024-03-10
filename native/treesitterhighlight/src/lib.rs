use rustler::{Atom, Error as NifError, NifResult, NifUnitEnum, Term as NifTerm};
use std::fmt::Write;
use tree_sitter::QueryError;
use tree_sitter_highlight::{
    Error as HighlightError, HighlightConfiguration, Highlighter, HtmlRenderer,
};

mod atoms {
    rustler::atoms! {
        elixir,
        javascript,
        unsupported_langauge,
    }
}

#[derive(NifUnitEnum)]
pub enum Language {
    Elixir,
    Javascript,
    Rust,
}

const HIGHLIGHT_NAMES: [&str; 22] = [
    "attribute",
    "comment",
    "constant",
    "constant.builtin",
    "constructor",
    "embedded",
    "function",
    "function.builtin",
    "keyword",
    "module",
    "number",
    "operator",
    "property",
    "punctuation.bracket",
    "punctuation.delimiter",
    "string",
    "string.special",
    "tag",
    "type",
    "type.builtin",
    "variable.builtin",
    "variable.parameter",
];

fn get_config(language: Atom) -> Result<HighlightConfiguration, NifError> {
    let config_result = if language == atoms::javascript() {
        HighlightConfiguration::new(
            tree_sitter_javascript::language(),
            tree_sitter_javascript::HIGHLIGHT_QUERY,
            tree_sitter_javascript::INJECTION_QUERY,
            tree_sitter_javascript::LOCALS_QUERY,
        )
    } else if language == atoms::elixir() {
        HighlightConfiguration::new(
            tree_sitter_elixir::language(),
            tree_sitter_elixir::HIGHLIGHTS_QUERY,
            "",
            "",
        )
    } else {
        return Err(NifError::Atom("unsupported_language"));
    };

    let mut config = match config_result {
        Ok(c) => c,
        Err(QueryError { message: m, .. }) => return Err(NifError::Term(Box::new(m))),
    };

    config.configure(&HIGHLIGHT_NAMES);
    Ok(config)
}

fn translate_highlight_error(e: HighlightError) -> NifError {
    match e {
        HighlightError::Cancelled => NifError::Atom("highlight_cancelled"),
        HighlightError::InvalidLanguage => NifError::Atom("highlight_invalid_language"),
        HighlightError::Unknown => NifError::Atom("highlight_unknown"),
    }
}

#[rustler::nif]
fn render_html(source_code: &str, language: NifTerm) -> NifResult<String> {
    let language: Atom = language.decode().unwrap();

    let html_attrs = HIGHLIGHT_NAMES.map(|s| format!(r#"class="{}""#, s.replace(".", "-")));
    let mut highlighter = Highlighter::new();
    let highlight_config = get_config(language)?;

    let source_code_bytes = source_code.as_bytes();
    let events = match highlighter.highlight(&highlight_config, source_code_bytes, None, |_| None) {
        Ok(events) => Ok(events),
        Err(e) => Err(translate_highlight_error(e)),
    }?;

    let mut renderer = HtmlRenderer::new();

    match renderer.render(events, source_code_bytes, &|highlight| {
        html_attrs[highlight.0].as_bytes()
    }) {
        Ok(_) => (),
        Err(e) => return Err(translate_highlight_error(e)),
    }

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

    Ok(html)
}

rustler::init!("Elixir.TreeSitterHighlight", [render_html]);
