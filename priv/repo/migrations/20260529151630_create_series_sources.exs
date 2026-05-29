defmodule Slipstream.Repo.Migrations.CreateSeriesSources do
  use Ecto.Migration

  def change do
    create table(:series_sources) do
      add :series_id, references(:series, on_delete: :delete_all), null: false
      add :name, :string, null: false
      add :url, :text, null: false
      add :source_type, :string, null: false, default: "calendar"
      add :format, :string, null: false, default: "html"
      add :http_method, :string, null: false, default: "GET"
      add :request_headers, :map, null: false, default: %{}
      add :request_params, :map, null: false, default: %{}
      add :extraction_config, :map, null: false, default: %{}
      add :is_active, :boolean, default: true, null: false
      add :priority, :integer, null: false, default: 0
      add :notes, :text

      timestamps(type: :utc_datetime)
    end

    create index(:series_sources, [:series_id])
    create index(:series_sources, [:source_type])
    create index(:series_sources, [:is_active])
    create unique_index(:series_sources, [:series_id, :url])
  end
end
