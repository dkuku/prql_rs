use prqlc::{sql::Dialect, DisplayOptions, Options, Target, ErrorMessages};
use rustler::Atom;
use thiserror::Error;

mod atoms {
    rustler::atoms! {
        // Dialects
        ansi,
        big_query,
        click_house,
        duck_db,
        generic,
        glare_db,
        ms_sql,
        my_sql,
        postgres,
        sqlite,
        snowflake,
        // Display options
        plain,
        ansi_color,
        // Option names
        format,
        target,
        signature_comment,
        color,
        display,
        nil
    }
}

use atoms::*;

#[derive(Error, Debug)]
pub enum PrqlError {
    #[error("Compilation error: {0}")]
    Compilation(String),
}

impl From<prqlc::ErrorMessages> for PrqlError {
    fn from(err: prqlc::ErrorMessages) -> Self {
        PrqlError::Compilation(err.to_string())
    }
}

fn get_options(options: Vec<(Atom, rustler::Term)>) -> Result<Options, String> {
    let mut opts = Options {
        format: false,
        signature_comment: false,
        color: false,
        display: DisplayOptions::Plain,
        target: Target::Sql(None),
    };

    for (key, value) in options {
        if key == format() {
            opts.format = value.decode().map_err(|e| format!("{:?}", e))?;
        } else if key == target() {
            if let Ok(Some(dialect)) = value.decode::<Option<Atom>>() {
                let dialect = match dialect {
                    atom if atom == ansi() => Dialect::Ansi,
                    atom if atom == big_query() => Dialect::BigQuery,
                    atom if atom == click_house() => Dialect::ClickHouse,
                    atom if atom == duck_db() => Dialect::DuckDb,
                    atom if atom == generic() => Dialect::Generic,
                    atom if atom == glare_db() => Dialect::GlareDb,
                    atom if atom == ms_sql() => Dialect::MsSql,
                    atom if atom == my_sql() => Dialect::MySql,
                    atom if atom == postgres() => Dialect::Postgres,
                    atom if atom == sqlite() => Dialect::SQLite,
                    atom if atom == snowflake() => Dialect::Snowflake,
                    // Default is generic
                    atom if atom == nil() => Dialect::Generic,
                    // This should never happen as Elixir validates the dialect
                    dialect => return Err(format!("Unknown dialect {:?}", dialect)),
                };
                opts.target = Target::Sql(Some(dialect));
            } else {
                opts.target = Target::Sql(None);
            }
        } else if key == signature_comment() {
            opts.signature_comment = value.decode().map_err(|e| format!("{:?}", e))?;
        } else if key == color() {
            opts.color = value.decode().map_err(|e| format!("{:?}", e))?;
        } else if key == display() {
            opts.display = match value.decode::<Atom>() {
                Ok(atom) if atom == ansi_color() => DisplayOptions::AnsiColor,
                _ => DisplayOptions::Plain,
            };
        }
        // Unknown options are filtered out by Elixir
    }

    Ok(opts)
}

fn format_prql_error(errors: ErrorMessages) -> String {
    // Get the first error message
    if let Some(first_error) = errors.inner.first() {
        // Format as "reason (hint)" if there's a hint, otherwise just the reason
        if let Some(first_hint) = first_error.hints.first() {
            format!("{} ({})", first_error.reason, first_hint)
        } else {
            first_error.reason.clone()
        }
    } else {
        // Fallback if there are no errors (shouldn't happen)
        "Unknown PRQL compilation error".to_string()
    }
}

#[rustler::nif]
fn compile(prql_query: &str, options: Vec<(Atom, rustler::Term)>) -> Result<String, String> {
    let opts = get_options(options)?;
    prqlc::compile(prql_query, &opts)
        .map_err(format_prql_error)
}
#[rustler::nif]
fn format(prql_query: &str) -> Result<String, String> {
    prqlc::prql_to_pl(prql_query)
        .and_then(|pl| prqlc::pl_to_prql(&pl))
        .map_err(format_prql_error)
}

rustler::init!("Elixir.Prql.Native", load = on_load);

fn on_load(env: rustler::Env, _info: rustler::Term) -> bool {
    let _ = rustler::resource!(PrqlError, env);
    true
}
