defmodule Slipstream.MotorsportTest do
  use Slipstream.DataCase

  alias Slipstream.Motorsport

  describe "series" do
    alias Slipstream.Motorsport.Series

    import Slipstream.MotorsportFixtures

    @invalid_attrs %{
      name: nil,
      description: nil,
      metadata: nil,
      short_name: nil,
      sport_type: nil,
      governing_body: nil,
      logo_url: nil,
      official_website: nil,
      is_active: nil
    }

    test "list_series/0 returns all series" do
      series = series_fixture()
      assert Motorsport.list_series() == [series]
    end

    test "get_series!/1 returns the series with given id" do
      series = series_fixture()
      assert Motorsport.get_series!(series.id) == series
    end

    test "create_series/1 with valid data creates a series" do
      valid_attrs = %{
        name: "some name",
        description: "some description",
        metadata: %{},
        short_name: "some short_name",
        sport_type: "some sport_type",
        governing_body: "some governing_body",
        logo_url: "some logo_url",
        official_website: "some official_website",
        is_active: true
      }

      assert {:ok, %Series{} = series} = Motorsport.create_series(valid_attrs)
      assert series.name == "some name"
      assert series.description == "some description"
      assert series.metadata == %{}
      assert series.short_name == "some short_name"
      assert series.sport_type == "some sport_type"
      assert series.governing_body == "some governing_body"
      assert series.logo_url == "some logo_url"
      assert series.official_website == "some official_website"
      assert series.is_active == true
    end

    test "create_series/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Motorsport.create_series(@invalid_attrs)
    end

    test "update_series/2 with valid data updates the series" do
      series = series_fixture()

      update_attrs = %{
        name: "some updated name",
        description: "some updated description",
        metadata: %{},
        short_name: "some updated short_name",
        sport_type: "some updated sport_type",
        governing_body: "some updated governing_body",
        logo_url: "some updated logo_url",
        official_website: "some updated official_website",
        is_active: false
      }

      assert {:ok, %Series{} = series} = Motorsport.update_series(series, update_attrs)
      assert series.name == "some updated name"
      assert series.description == "some updated description"
      assert series.metadata == %{}
      assert series.short_name == "some updated short_name"
      assert series.sport_type == "some updated sport_type"
      assert series.governing_body == "some updated governing_body"
      assert series.logo_url == "some updated logo_url"
      assert series.official_website == "some updated official_website"
      assert series.is_active == false
    end

    test "update_series/2 with invalid data returns error changeset" do
      series = series_fixture()
      assert {:error, %Ecto.Changeset{}} = Motorsport.update_series(series, @invalid_attrs)
      assert series == Motorsport.get_series!(series.id)
    end

    test "delete_series/1 deletes the series" do
      series = series_fixture()
      assert {:ok, %Series{}} = Motorsport.delete_series(series)
      assert_raise Ecto.NoResultsError, fn -> Motorsport.get_series!(series.id) end
    end

    test "change_series/1 returns a series changeset" do
      series = series_fixture()
      assert %Ecto.Changeset{} = Motorsport.change_series(series)
    end
  end

  describe "seasons" do
    alias Slipstream.Motorsport.Season

    import Slipstream.MotorsportFixtures

    @valid_attrs %{
      year: 2026,
      starts_on: ~D[2026-03-08],
      ends_on: ~D[2026-12-06],
      is_current: true
    }

    @invalid_attrs %{
      year: nil,
      starts_on: nil,
      ends_on: nil,
      is_current: nil
    }

    test "list_seasons/1 returns seasons scoped to a series" do
      series = series_fixture()
      other_series = series_fixture(name: "Other series", short_name: "OS")
      season = season_fixture(series: series, year: 2026)
      _other_season = season_fixture(series: other_series, year: 2025)

      assert [listed_season] = Motorsport.list_seasons(series)
      assert listed_season.id == season.id
    end

    test "get_season!/2 returns the season with given id in the series scope" do
      series = series_fixture()
      other_series = series_fixture(name: "Other series", short_name: "OS")
      season = season_fixture(series: series, year: 2026)

      assert Motorsport.get_season!(series, season.id).id == season.id

      assert_raise Ecto.NoResultsError, fn ->
        Motorsport.get_season!(other_series, season.id)
      end
    end

    test "create_season/2 with valid data creates a season" do
      series = series_fixture()

      assert {:ok, %Season{} = season} = Motorsport.create_season(series, @valid_attrs)
      assert season.series_id == series.id
      assert season.year == 2026
      assert season.starts_on == ~D[2026-03-08]
      assert season.ends_on == ~D[2026-12-06]
      assert season.is_current == true
    end

    test "create_season/2 with invalid data returns error changeset" do
      series = series_fixture()

      assert {:error, %Ecto.Changeset{}} = Motorsport.create_season(series, @invalid_attrs)
    end

    test "create_season/2 enforces unique years per series" do
      series = series_fixture()
      assert {:ok, %Season{}} = Motorsport.create_season(series, @valid_attrs)
      assert {:error, changeset} = Motorsport.create_season(series, @valid_attrs)

      assert "has already been taken" in errors_on(changeset).year
    end

    test "update_season/2 with valid data updates the season" do
      season = season_fixture()

      update_attrs = %{
        year: 2027,
        starts_on: ~D[2027-03-01],
        ends_on: ~D[2027-12-12],
        is_current: false
      }

      assert {:ok, %Season{} = season} = Motorsport.update_season(season, update_attrs)
      assert season.year == 2027
      assert season.starts_on == ~D[2027-03-01]
      assert season.ends_on == ~D[2027-12-12]
      assert season.is_current == false
    end

    test "update_season/2 with invalid data returns error changeset" do
      season = season_fixture()
      assert {:error, %Ecto.Changeset{}} = Motorsport.update_season(season, @invalid_attrs)
      assert season == Motorsport.get_season!(season.series_id, season.id)
    end

    test "delete_season/1 deletes the season" do
      season = season_fixture()
      assert {:ok, %Season{}} = Motorsport.delete_season(season)

      assert_raise Ecto.NoResultsError, fn ->
        Motorsport.get_season!(season.series_id, season.id)
      end
    end

    test "change_season/1 returns a season changeset" do
      season = season_fixture()
      assert %Ecto.Changeset{} = Motorsport.change_season(season)
    end
  end

  describe "series_sources" do
    alias Slipstream.Motorsport.SeriesSource

    import Slipstream.MotorsportFixtures

    @valid_attrs %{
      name: "Official calendar",
      priority: 1,
      format: "html",
      url: "https://example.com/calendar",
      source_type: "calendar",
      http_method: "GET",
      request_headers: %{},
      request_params: %{},
      extraction_config: %{"item_selector" => ".race-card"},
      is_active: true,
      notes: "some notes"
    }

    @invalid_attrs %{
      name: nil,
      priority: nil,
      format: nil,
      url: nil,
      source_type: nil,
      http_method: nil,
      is_active: nil
    }

    test "list_series_sources/1 returns sources scoped to a series" do
      series = series_fixture()
      other_series = series_fixture(name: "Other series", short_name: "OS")
      series_source = series_source_fixture(series: series)
      _other_source = series_source_fixture(series: other_series)

      assert [listed_source] = Motorsport.list_series_sources(series)
      assert listed_source.id == series_source.id
    end

    test "get_series_source!/2 returns the series_source with given id in the series scope" do
      series = series_fixture()
      other_series = series_fixture(name: "Other series", short_name: "OS")
      series_source = series_source_fixture(series: series)

      assert Motorsport.get_series_source!(series, series_source.id).id == series_source.id

      assert_raise Ecto.NoResultsError, fn ->
        Motorsport.get_series_source!(other_series, series_source.id)
      end
    end

    test "create_series_source/2 with valid data creates a series_source" do
      series = series_fixture()

      assert {:ok, %SeriesSource{} = series_source} =
               Motorsport.create_series_source(series, @valid_attrs)

      assert series_source.series_id == series.id
      assert series_source.name == "Official calendar"
      assert series_source.priority == 1
      assert series_source.format == "html"
      assert series_source.url == "https://example.com/calendar"
      assert series_source.source_type == "calendar"
      assert series_source.http_method == "GET"
      assert series_source.request_headers == %{}
      assert series_source.request_params == %{}
      assert series_source.extraction_config == %{"item_selector" => ".race-card"}
      assert series_source.is_active == true
      assert series_source.notes == "some notes"
    end

    test "create_series_source/2 with JSON textarea params decodes maps" do
      series = series_fixture()

      attrs =
        @valid_attrs
        |> Map.drop([:request_headers, :request_params, :extraction_config])
        |> Map.merge(%{
          request_headers_json: ~s({"accept": "text/html"}),
          request_params_json: ~s({"season": "2026"}),
          extraction_config_json: ~s({"item_selector": ".event"})
        })

      assert {:ok, %SeriesSource{} = series_source} =
               Motorsport.create_series_source(series, attrs)

      assert series_source.request_headers == %{"accept" => "text/html"}
      assert series_source.request_params == %{"season" => "2026"}
      assert series_source.extraction_config == %{"item_selector" => ".event"}
    end

    test "create_series_source/2 with invalid data returns error changeset" do
      series = series_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Motorsport.create_series_source(series, @invalid_attrs)
    end

    test "create_series_source/2 validates allowed values and JSON objects" do
      series = series_fixture()

      attrs =
        Map.merge(@valid_attrs, %{
          source_type: "bad",
          format: "bad",
          http_method: "PUT",
          extraction_config_json: "[1, 2]"
        })

      assert {:error, changeset} = Motorsport.create_series_source(series, attrs)
      assert "is invalid" in errors_on(changeset).source_type
      assert "is invalid" in errors_on(changeset).format
      assert "is invalid" in errors_on(changeset).http_method
      assert "must be a JSON object" in errors_on(changeset).extraction_config_json
    end

    test "create_series_source/2 enforces unique URLs per series" do
      series = series_fixture()
      assert {:ok, %SeriesSource{}} = Motorsport.create_series_source(series, @valid_attrs)
      assert {:error, changeset} = Motorsport.create_series_source(series, @valid_attrs)

      assert "has already been taken" in errors_on(changeset).url
    end

    test "update_series_source/2 with valid data updates the series_source" do
      series_source = series_source_fixture()

      update_attrs = %{
        name: "Updated calendar",
        priority: 2,
        format: "json",
        url: "https://example.com/updated-calendar",
        source_type: "results",
        http_method: "POST",
        request_headers: %{"accept" => "application/json"},
        request_params: %{},
        extraction_config: %{"items_path" => "data.races"},
        is_active: false,
        notes: "some updated notes"
      }

      assert {:ok, %SeriesSource{} = series_source} =
               Motorsport.update_series_source(series_source, update_attrs)

      assert series_source.name == "Updated calendar"
      assert series_source.priority == 2
      assert series_source.format == "json"
      assert series_source.url == "https://example.com/updated-calendar"
      assert series_source.source_type == "results"
      assert series_source.http_method == "POST"
      assert series_source.request_headers == %{"accept" => "application/json"}
      assert series_source.request_params == %{}
      assert series_source.extraction_config == %{"items_path" => "data.races"}
      assert series_source.is_active == false
      assert series_source.notes == "some updated notes"
    end

    test "update_series_source/2 with invalid data returns error changeset" do
      series_source = series_source_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Motorsport.update_series_source(series_source, @invalid_attrs)

      persisted_source = Motorsport.get_series_source!(series_source.series_id, series_source.id)
      assert persisted_source.name == series_source.name
      assert persisted_source.url == series_source.url
      assert persisted_source.extraction_config == series_source.extraction_config
    end

    test "delete_series_source/1 deletes the series_source" do
      series_source = series_source_fixture()
      assert {:ok, %SeriesSource{}} = Motorsport.delete_series_source(series_source)

      assert_raise Ecto.NoResultsError, fn ->
        Motorsport.get_series_source!(series_source.series_id, series_source.id)
      end
    end

    test "change_series_source/1 returns a series_source changeset" do
      series_source = series_source_fixture()
      assert %Ecto.Changeset{} = Motorsport.change_series_source(series_source)
    end
  end
end
