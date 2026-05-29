defmodule Slipstream.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events) do
      add :season_id, references(:seasons, on_delete: :delete_all), null: false
      add :round, :integer, null: false
      add :name, :string, null: false
      add :venue_name, :string
      add :location, :string
      add :country, :string
      add :starts_on, :date
      add :ends_on, :date
      add :timezone, :string
      add :status, :string, null: false, default: "scheduled"
      add :sessions, :map, null: false, default: %{}

      timestamps(type: :utc_datetime)
    end

    create index(:events, [:season_id])
    create index(:events, [:status])
    create unique_index(:events, [:season_id, :round])
  end
end
