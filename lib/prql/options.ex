defmodule Prql.Options do
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

  @default_options [
    format: false,
    target: nil,
    signature_comment: false,
    color: false,
    display: :plain
  ]

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

  @type display_option :: :plain | :ansi_color
  @type option ::
          {:format, boolean()}
          | {:target, dialect() | nil}
          | {:signature_comment, boolean()}
          | {:color, boolean()}
          | {:display, display_option()}
  @type options :: [option()]

  @doc """
  Normalizes and validates compilation options.

  Returns `{:ok, normalized_options}` on success, or `{:error, reason}` on failure.
  """
  @spec normalize(options()) :: {:ok, options()} | {:error, String.t()}
  def normalize(options) when is_list(options) do
    options =
      @default_options
      |> Keyword.merge(
        Keyword.take(options, [:format, :target, :signature_comment, :color, :display])
      )

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
end
