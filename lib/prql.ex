defmodule Prql do
  @moduledoc """
  PRQL compiler for Elixir, powered by Rust's prqlc.
  """

  alias Prql.Options

  @type option :: Options.option()
  @type options :: Options.options()
  @type dialect :: Options.dialect()
  @type display_option :: Options.display_option()

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
end
