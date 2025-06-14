defmodule Prql.Native do
  @moduledoc false

  use Rustler, otp_app: :prql_rs, crate: "prql_native"

  @doc false
  @spec compile(String.t(), keyword()) :: {:ok, String.t()} | {:error, String.t()}
  def compile(prql_query, options) when is_binary(prql_query) and is_list(options) do
    compile_nif(prql_query, options)
  end

  @doc false
  @spec format(String.t()) :: {:ok, String.t()} | {:error, String.t()}
  def format(prql_query) when is_binary(prql_query) do
    format_nif(prql_query)
  end

  defp compile_nif(_prql_query, _options) do
    :erlang.nif_error(:nif_not_loaded)
  end

  defp format_nif(_prql_query) do
    :erlang.nif_error(:nif_not_loaded)
  end
end
