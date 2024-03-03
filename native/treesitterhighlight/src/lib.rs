use rustler::{Error as RustlerError, NifStruct, NifUnitEnum, Term as RustlerTerm};
use tree_sitter_highlight::Error as TSError;
use tree_sitter_highlight::HighlightConfiguration;
use tree_sitter_highlight::HighlightEvent;
use tree_sitter_highlight::Highlighter;

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

#[derive(NifStruct)]
#[module = "TreeSitterHighlight.HighlightEvent"]
pub struct ExHighlightEvent {
    pub event_type: String,
    pub start: usize,
    pub end: usize,
}

static HIGHLIGHT_NAMES: [&str; 18] = [
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

fn make_ex_events(
    events: impl Iterator<Item = Result<HighlightEvent, TSError>>,
) -> Vec<ExHighlightEvent> {
    let mut ex_events: Vec<ExHighlightEvent> = Vec::new();
    for event in events {
        let ex_event = match event.unwrap() {
            HighlightEvent::Source { start, end } => ExHighlightEvent {
                start,
                end,
                event_type: String::from("source"),
            },
            HighlightEvent::HighlightStart(start) => ExHighlightEvent {
                event_type: String::from("highlight start"),
                start: 0,
                end: 0,
            },
            HighlightEvent::HighlightEnd => ExHighlightEvent {
                event_type: String::from("highlight end"),
                start: 0,
                end: 0,
            },
        };
        ex_events.push(ex_event);
    }
    ex_events
}

#[rustler::nif]
fn highlight_code(code: &str) -> Vec<ExHighlightEvent> {
    let mut highlighter = Highlighter::new();
    let highlight_config = get_config();
    let events = highlighter
        .highlight(&highlight_config, code.as_bytes(), None, |_| None)
        .unwrap();

    make_ex_events(events)
}

rustler::init!("Elixir.TreeSitterHighlight", [highlight_code]);
