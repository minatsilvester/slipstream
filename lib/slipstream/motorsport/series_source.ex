defmodule Slipstream.Motorsport.SeriesSource do
  use Ecto.Schema
  import Ecto.Changeset

  @source_types ~w(calendar results standings metadata)
  @formats ~w(html json ical csv)
  @http_methods ~w(GET POST)
  @map_fields [:request_headers, :request_params, :extraction_config]

  schema "series_sources" do
    field :name, :string
    field :url, :string
    field :source_type, :string, default: "calendar"
    field :format, :string, default: "html"
    field :http_method, :string, default: "GET"
    field :request_headers, :map, default: %{}
    field :request_headers_json, :string, virtual: true
    field :request_params, :map, default: %{}
    field :request_params_json, :string, virtual: true
    field :extraction_config, :map, default: %{}
    field :extraction_config_json, :string, virtual: true
    field :is_active, :boolean, default: true
    field :priority, :integer, default: 0
    field :notes, :string
    belongs_to :series, Slipstream.Motorsport.Series

    timestamps(type: :utc_datetime)
  end

  def source_types, do: @source_types
  def formats, do: @formats
  def http_methods, do: @http_methods

  @doc false
  def changeset(series_source, attrs) do
    series_source
    |> cast(attrs, [
      :name,
      :url,
      :source_type,
      :format,
      :http_method,
      :request_headers,
      :request_headers_json,
      :request_params,
      :request_params_json,
      :extraction_config,
      :extraction_config_json,
      :is_active,
      :priority,
      :notes
    ])
    |> put_json_textarea_defaults(attrs)
    |> decode_json_textarea(:request_headers_json, :request_headers)
    |> decode_json_textarea(:request_params_json, :request_params)
    |> decode_json_textarea(:extraction_config_json, :extraction_config)
    |> validate_required([
      :name,
      :url,
      :source_type,
      :format,
      :http_method,
      :is_active,
      :priority
    ])
    |> validate_inclusion(:source_type, @source_types)
    |> validate_inclusion(:format, @formats)
    |> validate_inclusion(:http_method, @http_methods)
    |> validate_number(:priority, greater_than_or_equal_to: 0)
    |> unique_constraint(:url, name: :series_sources_series_id_url_index)
  end

  defp put_json_textarea_defaults(changeset, attrs) do
    Enum.reduce(@map_fields, changeset, fn field, changeset ->
      json_field = :"#{field}_json"

      if json_attr_present?(attrs, json_field) do
        changeset
      else
        put_change(changeset, json_field, encode_map(get_field(changeset, field)))
      end
    end)
  end

  defp decode_json_textarea(changeset, json_field, map_field) do
    if changed?(changeset, json_field) do
      json = get_field(changeset, json_field) || ""

      case Jason.decode(json) do
        {:ok, decoded} when is_map(decoded) ->
          put_change(changeset, map_field, decoded)

        {:ok, _decoded} ->
          add_error(changeset, json_field, "must be a JSON object")

        {:error, _error} ->
          add_error(changeset, json_field, "must be valid JSON")
      end
    else
      changeset
    end
  end

  defp encode_map(nil), do: "{}"

  defp encode_map(map) when is_map(map) do
    Jason.encode!(map, pretty: true)
  end

  defp json_attr_present?(attrs, field) when is_map(attrs) do
    Map.has_key?(attrs, field) or Map.has_key?(attrs, Atom.to_string(field))
  end

  defp json_attr_present?(_attrs, _field), do: false
end
