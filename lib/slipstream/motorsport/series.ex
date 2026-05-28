defmodule Slipstream.Motorsport.Series do
  use Ecto.Schema
  import Ecto.Changeset

  schema "series" do
    field :name, :string
    field :short_name, :string
    field :description, :string
    field :sport_type, :string
    field :governing_body, :string
    field :logo_url, :string
    field :official_website, :string
    field :is_active, :boolean, default: false
    field :metadata, :map

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(series, attrs) do
    series
    |> cast(attrs, [:name, :short_name, :description, :sport_type, :governing_body, :logo_url, :official_website, :is_active, :metadata])
    |> validate_required([:name, :short_name, :description, :sport_type, :governing_body, :logo_url, :official_website, :is_active])
  end
end
