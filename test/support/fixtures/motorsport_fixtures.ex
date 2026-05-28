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
end
