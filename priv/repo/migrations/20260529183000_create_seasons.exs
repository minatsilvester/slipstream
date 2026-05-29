defmodule Slipstream.Repo.Migrations.CreateSeasons do
  use Ecto.Migration

  def change do
    create table(:seasons) do
      add :series_id, references(:series, on_delete: :delete_all), null: false
      add :year, :integer, null: false
      add :starts_on, :date
      add :ends_on, :date
      add :is_current, :boolean, default: false, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:seasons, [:series_id])
    create index(:seasons, [:year])
    create index(:seasons, [:is_current])
    create unique_index(:seasons, [:series_id, :year])
  end
end
