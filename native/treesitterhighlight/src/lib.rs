#[macro_use]
extern crate lazy_static;

use rustler::{Atom, Error as NifError, NifResult, Term as NifTerm};
use std::fmt::Write;
use tree_sitter_highlight::{
    Error as HighlightError, HighlightConfiguration, Highlighter, HtmlRenderer,
};

mod atoms {
    rustler::atoms! {
       elixir,
       highlight_cancelled,
       highlight_invalid_language,
       highlight_unknown,
       html,
       javascript,
       css,
       ok,
       rust,
       unsupported_language,
    }
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

lazy_static! {
    static ref JS_CONFIG: HighlightConfiguration = {
        let mut c = HighlightConfiguration::new(
            tree_sitter_javascript::language(),
            tree_sitter_javascript::HIGHLIGHT_QUERY,
            tree_sitter_javascript::INJECTION_QUERY,
            tree_sitter_javascript::LOCALS_QUERY,
        )
        .unwrap();
        c.configure(&HIGHLIGHT_NAMES);
        c
    };
    static ref ELIXIR_CONFIG: HighlightConfiguration = {
        let mut c = HighlightConfiguration::new(
            tree_sitter_elixir::language(),
            tree_sitter_elixir::HIGHLIGHTS_QUERY,
            r#"((sigil
            (sigil_name) @_sigil_name
            (quoted_content) @injection.content)
            (#eq? @_sigil_name "H")
            (#set! injection.language "heex")
            (#set! injection.combined))"#,
            "",
        )
        .unwrap();
        c.configure(&HIGHLIGHT_NAMES);
        c
    };
    static ref RUST_CONFIG: HighlightConfiguration = {
        let mut c = HighlightConfiguration::new(
            tree_sitter_rust::language(),
            tree_sitter_rust::HIGHLIGHT_QUERY,
            tree_sitter_rust::INJECTIONS_QUERY,
            "",
        )
        .unwrap();
        c.configure(&HIGHLIGHT_NAMES);
        c
    };
    static ref CSS_CONFIG: HighlightConfiguration = {
        let mut c = HighlightConfiguration::new(
            tree_sitter_css::language(),
            tree_sitter_css::HIGHLIGHTS_QUERY,
            "",
            "",
        )
        .unwrap();
        c.configure(&HIGHLIGHT_NAMES);
        c
    };
    static ref HTML_CONFIG: HighlightConfiguration = {
        let mut c = HighlightConfiguration::new(
            tree_sitter_html::language(),
            tree_sitter_html::HIGHLIGHTS_QUERY,
            tree_sitter_html::INJECTIONS_QUERY,
            "",
        )
        .unwrap();
        c.configure(&HIGHLIGHT_NAMES);
        c
    };
}

fn translate_highlight_error(e: HighlightError) -> NifError {
    NifError::Term(Box::new(match e {
        HighlightError::Cancelled => atoms::highlight_cancelled(),
        HighlightError::InvalidLanguage => atoms::highlight_invalid_language(),
        HighlightError::Unknown => atoms::highlight_unknown(),
    }))
}

#[rustler::nif]
fn render_html<'a>(source_code: &str, l: NifTerm) -> NifResult<(Atom, String)> {
    let lang = l.atom_to_string().unwrap();

    let get_config = |lang: &str| {
        Some(match lang {
            "javascript" => &*JS_CONFIG,
            "elixir" => &*ELIXIR_CONFIG,
            "rust" => &*RUST_CONFIG,
            "html" => &*HTML_CONFIG,
            "css" => &*CSS_CONFIG,
            _ => {
                return None;
            }
        })
    };

    let highlight_config = match get_config(lang.as_str()) {
        Some(c) => c,
        _ => {
            return Err(NifError::Term(Box::new(atoms::unsupported_language())));
        }
    };

    let html_attrs = HIGHLIGHT_NAMES.map(|s| format!(r#"class="token {}""#, s.replace(".", " ")));
    let mut highlighter = Highlighter::new();

    let source_code_bytes = source_code.as_bytes();
    let highlight_result =
        highlighter.highlight(highlight_config, source_code_bytes, None, get_config);

    let events = match highlight_result {
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
    writeln!(html, r#"<pre class="code-block language-{lang}"><code>"#).unwrap();
    for (i, line) in renderer.lines().enumerate() {
        writeln!(
            html,
            r#"<div class="line-wrapper"><span class="line-number">{}</span>{}</div>"#,
            i + 1,
            line,
        )
        .unwrap();
    }
    writeln!(html, r#"</code></pre>"#).unwrap();

    Ok((atoms::ok(), html))
}

rustler::init!("Elixir.TreeSitterHighlight", [render_html]);
