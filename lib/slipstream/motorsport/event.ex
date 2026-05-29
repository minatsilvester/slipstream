defmodule Slipstream.Motorsport.Event do
  use Ecto.Schema
  import Ecto.Changeset

  @statuses ~w(scheduled cancelled postponed rescheduled)
  @json_fields [:sessions]

  schema "events" do
    field :round, :integer
    field :name, :string
    field :venue_name, :string
    field :location, :string
    field :country, :string
    field :starts_on, :date
    field :ends_on, :date
    field :timezone, :string
    field :status, :string, default: "scheduled"
    field :sessions, :map, default: %{}
    field :sessions_json, :string, virtual: true
    belongs_to :season, Slipstream.Motorsport.Season

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(event, attrs) do
    event
    |> cast(attrs, [
      :round,
      :name,
      :venue_name,
      :location,
      :country,
      :starts_on,
      :ends_on,
      :timezone,
      :status,
      :sessions,
      :sessions_json
    ])
    |> put_json_textarea_defaults(attrs)
    |> decode_json_textarea(:sessions_json, :sessions)
    |> validate_required([:round, :name, :status])
    |> validate_number(:round, greater_than_or_equal_to: 1)
    |> validate_inclusion(:status, @statuses)
    |> unique_constraint(:round, name: :events_season_id_round_index)
  end

  defp put_json_textarea_defaults(changeset, attrs) do
    Enum.reduce(@json_fields, changeset, fn field, changeset ->
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
