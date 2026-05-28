defmodule Slipstream.MotorsportTest do
  use Slipstream.DataCase

  alias Slipstream.Motorsport

  describe "series" do
    alias Slipstream.Motorsport.Series

    import Slipstream.MotorsportFixtures

    @invalid_attrs %{name: nil, description: nil, metadata: nil, short_name: nil, sport_type: nil, governing_body: nil, logo_url: nil, official_website: nil, is_active: nil}

    test "list_series/0 returns all series" do
      series = series_fixture()
      assert Motorsport.list_series() == [series]
    end

    test "get_series!/1 returns the series with given id" do
      series = series_fixture()
      assert Motorsport.get_series!(series.id) == series
    end

    test "create_series/1 with valid data creates a series" do
      valid_attrs = %{name: "some name", description: "some description", metadata: %{}, short_name: "some short_name", sport_type: "some sport_type", governing_body: "some governing_body", logo_url: "some logo_url", official_website: "some official_website", is_active: true}

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
      update_attrs = %{name: "some updated name", description: "some updated description", metadata: %{}, short_name: "some updated short_name", sport_type: "some updated sport_type", governing_body: "some updated governing_body", logo_url: "some updated logo_url", official_website: "some updated official_website", is_active: false}

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
end
