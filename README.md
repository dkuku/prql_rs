# Prql

PRQL (Pipelined Relational Query Language) compiler for Elixir, powered by Rust's `prqlc`.

## Features

- Compile PRQL queries to SQL
- Support for multiple SQL dialects
- Configurable output formatting
- Clean error messages with helpful hints

## Installation

Add `prql` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:prql, "~> 0.1.0"}
  ]
end
```

## Usage

```elixir
# Basic usage
{:ok, sql} = Prql.compile("from employees | select {name, age}")
#=> {:ok, "SELECT name, age FROM employees"}

# With options
{:ok, sql} = Prql.compile("from employees | select {name, age}", 
  format: true, 
  target: :postgres
)

# Error handling
{:error, reason} = Prql.compile("invalid prql")
#=> {:error, "PRQL compilation error (unexpected token)"}
```

### Options

- `:format` - Whether to format the SQL output (default: `false`)
- `:target` - The SQL dialect to target (e.g., `:postgres`, `:mysql`, `:snowflake`)
- `:signature_comment` - Whether to include the PRQL signature comment (default: `false`)
- `:color` - Whether to enable color in the output (default: `false`)
- `:display` - Display options (`:plain` or `:ansi_color`)

## Error Handling

PRQL compilation errors include helpful error messages with hints. For example:

```elixir
{:error, reason} = Prql.compile("from employees | select {name,}")
#=> {:error, "Unexpected token (Expected an identifier after .)"}
```

## Development

### Building the NIF

The NIF is built automatically when compiling the Elixir code. For development, you can build it manually:

```bash
cd native/prql_native
cargo build
```

### Running Tests

```bash
mix test
```

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.
