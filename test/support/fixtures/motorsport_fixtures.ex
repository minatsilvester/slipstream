defmodule Slipstream.MotorsportFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Slipstream.Motorsport` context.
  """

  @doc """
  Generate a series.
  """
  def series_fixture(attrs \\ %{}) do
    {:ok, series} =
      attrs
      |> Enum.into(%{
        description: "some description",
        governing_body: "some governing_body",
        is_active: true,
        logo_url: "some logo_url",
        metadata: %{},
        name: "some name",
        official_website: "some official_website",
        short_name: "some short_name",
        sport_type: "some sport_type"
      })
      |> Slipstream.Motorsport.create_series()

    series
  end

  @doc """
  Generate a series_source.
  """
  def series_source_fixture(attrs \\ %{}) do
    attrs = Map.new(attrs)
    series = Map.get_lazy(attrs, :series, fn -> series_fixture() end)
    attrs = Map.drop(attrs, [:series])

    {:ok, series_source} =
      attrs
      |> Enum.into(%{
        extraction_config: %{"item_selector" => ".race-card"},
        format: "html",
        http_method: "GET",
        is_active: true,
        name: "some name",
        notes: "some notes",
        priority: 0,
        request_headers: %{},
        request_params: %{},
        source_type: "calendar",
        url: "https://example.com/calendar"
      })
      |> then(&Slipstream.Motorsport.create_series_source(series, &1))

    series_source
  end

  @doc """
  Generate a season.
  """
  def season_fixture(attrs \\ %{}) do
    attrs = Map.new(attrs)
    series = Map.get_lazy(attrs, :series, fn -> series_fixture() end)
    attrs = Map.drop(attrs, [:series])

    {:ok, season} =
      attrs
      |> Enum.into(%{
        ends_on: ~D[2026-12-31],
        is_current: true,
        starts_on: ~D[2026-03-08],
        year: 2026
      })
      |> then(&Slipstream.Motorsport.create_season(series, &1))

    season
  end
end
