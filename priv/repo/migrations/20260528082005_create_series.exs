defmodule Slipstream.Repo.Migrations.CreateSeries do
  use Ecto.Migration

  def change do
    create table(:series) do
      add :name, :string
      add :short_name, :string
      add :description, :text
      add :sport_type, :string
      add :governing_body, :string
      add :logo_url, :string
      add :official_website, :string
      add :is_active, :boolean, default: false, null: false
      add :metadata, :map

      timestamps(type: :utc_datetime)
    end

    create index(:series, [:sport_type])
    create index(:series, [:is_active])
  end
end
