defmodule Slipstream.Motorsport.Season do
  use Ecto.Schema
  import Ecto.Changeset

  schema "seasons" do
    field :year, :integer
    field :starts_on, :date
    field :ends_on, :date
    field :is_current, :boolean, default: false
    belongs_to :series, Slipstream.Motorsport.Series
    has_many :events, Slipstream.Motorsport.Event

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(season, attrs) do
    season
    |> cast(attrs, [:year, :starts_on, :ends_on, :is_current])
    |> validate_required([:year, :is_current])
    |> validate_number(:year, greater_than_or_equal_to: 1900)
    |> unique_constraint(:year, name: :seasons_series_id_year_index)
  end
end
