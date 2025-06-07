defmodule Prql do
  @moduledoc """
  PRQL compiler for Elixir, powered by Rust's prqlc.
  """

  alias Prql.Options

  @type option :: Options.option()
  @type options :: Options.options()
  @type dialect :: Options.dialect()
  @type display_option :: Options.display_option()
  @type format_error :: {:error, String.t()}

  @doc """
  Compiles a PRQL query to SQL.

  ## Options

  - `:format` - Whether to format the SQL output (default: `false`)
  - `:target` - The SQL dialect to target (optional, no default)
  - `:signature_comment` - Whether to include the PRQL signature comment (default: `false`)
  - `:color` - Whether to enable color in the output (default: `false`)
  - `:display` - Display options for the output (`:plain` or `:ansi_color`, default: `:plain`)

  ## Examples

      iex> Prql.compile("from employees | select {name, age}")
      {:ok, "SELECT name, age FROM employees"}

      iex> Prql.compile("from employees | select {name, age}", target: :postgres)
      {:ok, "SELECT name, age FROM employees"}

  Returns `{:ok, sql_string}` on success, or `{:error, reason}` on failure.
  """
  @spec compile(String.t(), options()) :: {:ok, String.t()} | {:error, String.t()}
  def compile(prql_query, options \\ []) when is_binary(prql_query) and is_list(options) do
    with {:ok, normalized_options} <- Options.normalize(options) do
      Prql.Native.compile(prql_query, normalized_options)
    end
  end

  @doc """
  Same as `compile/2` but raises an exception if compilation fails.

  ## Options

  See `compile/2` for available options.

  ## Examples

      iex> Prql.compile!("from employees | select {name, age}")
      "SELECT name, age FROM employees"

      iex> Prql.compile!("from employees | select {name, age}", target: :postgres)
      "SELECT name, age FROM employees"

      iex> Prql.compile!("invalid prql")
      ** (RuntimeError) PRQL compilation failed: ...
  """
  @spec compile!(String.t(), options()) :: String.t() | no_return()
  def compile!(prql_query, options \\ []) do
    case compile(prql_query, options) do
      {:ok, sql} -> sql
      {:error, reason} -> raise "PRQL compilation failed: #{reason}"
    end
  end

  @doc """
  Formats a PRQL query according to the standard style.

  ## Examples

      iex> Prql.format("from employees | select {name, age}")
      {:ok, "\""
      from employees
      select {name, age}
      "\""}

      iex> Prql.format("invalid prql")
      {:error, "unexpected keyword prql"}
  """
  @spec format(String.t()) :: {:ok, String.t()} | format_error()
  def format(prql_query) when is_binary(prql_query) do
    Prql.Native.format(prql_query)
  end

  @doc """
  Same as `format/1` but raises an exception if formatting fails.

  ## Examples

      iex> Prql.format!("from employees | select {name, age}")
      ""\"
      from employees
      select {name, age}
      ""\"

      iex> Prql.format!("invalid prql")
      ** (RuntimeError) PRQL formatting failed: ...
  """
  @spec format!(String.t()) :: String.t() | no_return()
  def format!(prql_query) do
    case format(prql_query) do
      {:ok, formatted} -> formatted
      {:error, reason} -> raise "PRQL formatting failed: #{reason}"
    end
  end
end
