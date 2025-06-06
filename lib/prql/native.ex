defmodule Prql.Native do
  @moduledoc """
  NIF bindings for the PRQL compiler.
  """
  use Rustler, otp_app: :prql_rs, crate: "prql_native"

  @dialect [
    :ansi,
    :big_query,
    :click_house,
    :duck_db,
    :generic,
    :glare_db,
    :ms_sql,
    :my_sql,
    :postgres,
    :sqlite,
    :snowflake
  ]

  @typedoc """
  Dialect specifies the SQL dialect to target.
  """
  @type dialect ::
          :ansi
          | :big_query
          | :click_house
          | :duck_db
          | :generic
          | :glare_db
          | :ms_sql
          | :my_sql
          | :postgres
          | :sqlite
          | :snowflake

  @typedoc """
  Display options for the output SQL.

  - `:plain` - Plain text output
  - `:ansi_color` - Output with ANSI color codes
  """
  @type display_option :: :plain | :ansi_color

  @typedoc """
  Compilation options for the PRQL compiler.

  ## Options

  - `:format` - Whether to format the SQL output (default: `true`)
  - `:target` - The SQL dialect to target (optional, no default)
  - `:signature_comment` - Whether to include the PRQL signature comment (default: `true`)
  - `:color` - Whether to enable color in the output (default: `false`)
  - `:display` - Display options for the output (`:plain` or `:ansi_color`)

  ## Default Options

  ```elixir
  [
    format: true,
    target: nil,
    signature_comment: true,
    color: false,
    display: :plain
  ]
  ```
  """
  @type option ::
          {:format, boolean()}
          | {:target, dialect() | nil}
          | {:signature_comment, boolean()}
          | {:color, boolean()}
          | {:display, display_option()}
  @type options :: [option()]

  @default_options [
    format: false,
    target: nil,
    signature_comment: false,
    color: false,
    display: :plain
  ]

  @doc """
  Compiles a PRQL query to SQL with default options.

  This is equivalent to calling `compile(prql_query, [])`.

  ## Default Options

  ```elixir
  [
    format: false,
    target: nil,
    signature_comment: false,
    color: false,
    display: :plain
  ]
  ```

  ## Examples

      iex> Prql.Native.compile("from employees | select {name, age}")
      {:ok, "SELECT name, age FROM employees"}

  Returns `{:ok, sql_string}` on success, or `{:error, reason}` on failure.
  """
  @spec compile(String.t()) :: {:ok, String.t()} | {:error, String.t()}
  def compile(prql_query) when is_binary(prql_query) do
    compile(prql_query, [])
  end

  @doc """
  Compiles a PRQL query to SQL with the given options.

  ## Options

  See the `t:option/0` type for available options and their descriptions.

  ## Default Options

  ```elixir
  [
    format: false,
    target: nil,
    signature_comment: false,
    color: false,
    display: :plain
  ]
  ```

  ## Examples

      # With custom options
      iex> Prql.Native.compile("from employees | select {name, age}",
      ...>   target: :postgres,
      ...>   format: true
      ...> )
      {:ok, "SELECT name, age\nFROM employees"}

  Returns `{:ok, sql_string}` on success, or `{:error, reason}` on failure.
  """
  @spec compile(String.t(), options()) :: {:ok, String.t()} | {:error, String.t()}
  def compile(prql_query, options) when is_binary(prql_query) and is_list(options) do
    case normalize_options(options) do
      {:ok, normalized_options} ->
        compile_nif(prql_query, normalized_options)

      {:error, reason} ->
        {:error, reason}
    end
  end

  @spec normalize_options(keyword()) :: {:ok, keyword()} | {:error, String.t()}
  defp normalize_options(options) when is_list(options) do
    # Start with default options and merge user options
    options =
      @default_options
      |> Keyword.merge(
        Keyword.take(options, [:format, :target, :signature_comment, :color, :display])
      )

    # Validate all options
    with :ok <- validate_known_options(options, @default_options),
         :ok <- validate_target(options[:target]),
         :ok <- validate_display(options[:display]),
         :ok <- validate_booleans(options, [:format, :signature_comment, :color]) do
      {:ok, options}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp validate_known_options(options, default_options) do
    known_keys = Keyword.keys(default_options)

    case Enum.find(options, fn {k, _v} -> k not in known_keys end) do
      nil -> :ok
      {key, _} -> {:error, "Unknown option: #{key}"}
    end
  end

  defp validate_target(nil), do: :ok
  defp validate_target(dialect) when dialect in @dialect, do: :ok
  defp validate_target(invalid), do: {:error, "Unknown dialect: #{inspect(invalid)}"}

  defp validate_display(display) when display in [nil, :plain, :ansi_color], do: :ok
  defp validate_display(invalid), do: {:error, "Invalid display option: #{inspect(invalid)}"}

  defp validate_booleans(options, keys) do
    case Enum.find(keys, fn key ->
           value = options[key]
           not is_nil(value) and not is_boolean(value)
         end) do
      nil -> :ok
      key -> {:error, "Option #{key} must be a boolean"}
    end
  end

  defp compile_nif(_prql_query, _options) do
    :erlang.nif_error(:nif_not_loaded)
  end
end
