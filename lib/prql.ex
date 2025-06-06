defmodule Prql do
  @moduledoc """
  PRQL compiler for Elixir, powered by Rust's prqlc.
  """

  @doc """
  Compiles a PRQL query to SQL.

  ## Examples

    iex> Prql.compile("from employees | select {name, age}")
    {:ok, "SELECT name, age FROM employees"}

  Returns `{:ok, sql_string}` on success, or `{:error, reason}` on failure.
  """
  @spec compile(String.t(), Keyword.t()) :: {:ok, String.t()} | {:error, String.t()}
  defdelegate compile(prql_query, options \\ []), to: Prql.Native

  @doc """
  Same as `compile/1` but raises an exception if compilation fails.

  ## Examples

    iex> Prql.compile!("from employees | select {name, age}")
    "SELECT name, age FROM employees"

    iex> Prql.compile!("invalid prql")
    ** (RuntimeError) PRQL compilation failed: ...
  """
  @spec compile!(String.t(), Keyword.t()) :: String.t() | no_return()
  def compile!(prql_query, options \\ []) do
    case compile(prql_query, options) do
      {:ok, sql} -> sql
      {:error, reason} -> raise "PRQL compilation failed: #{reason}"
    end
  end
end
