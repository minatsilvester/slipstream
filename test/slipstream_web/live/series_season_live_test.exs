defmodule SlipstreamWeb.SeriesSeasonLiveTest do
  use SlipstreamWeb.ConnCase

  import Phoenix.LiveViewTest
  import Slipstream.MotorsportFixtures

  @create_attrs %{
    year: 2027,
    starts_on: "2027-03-08",
    ends_on: "2027-12-06",
    is_current: true
  }

  @update_attrs %{
    year: 2027,
    starts_on: "2027-03-01",
    ends_on: "2027-12-12",
    is_current: false
  }

  @invalid_attrs %{
    year: nil,
    starts_on: nil,
    ends_on: nil,
    is_current: false
  }

  defp create_series_season(_) do
    series = series_fixture()
    season = season_fixture(series: series)

    %{series: series, season: season}
  end

  describe "Index" do
    setup [:create_series_season]

    test "lists all seasons for a series", %{conn: conn, series: series, season: season} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/series/#{series}/seasons")

      assert has_element?(index_live, "#series-seasons")
      assert has_element?(index_live, "#series_seasons-#{season.id}")
    end

    test "saves new season", %{conn: conn, series: series} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/series/#{series}/seasons")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Season")
               |> render_click()
               |> follow_redirect(conn, ~p"/admin/series/#{series}/seasons/new")

      assert has_element?(form_live, "#series-season-form")

      assert form_live
             |> form("#series-season-form", season: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#series-season-form", season: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/admin/series/#{series}/seasons")

      assert has_element?(index_live, "#series-seasons")
      assert render(index_live) =~ "Season created successfully"
    end

    test "updates season in listing", %{conn: conn, series: series, season: season} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/series/#{series}/seasons")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#series_seasons-#{season.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/admin/series/#{series}/seasons/#{season}/edit")

      assert has_element?(form_live, "#series-season-form")

      assert {:ok, index_live, _html} =
               form_live
               |> form("#series-season-form", season: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/admin/series/#{series}/seasons")

      assert has_element?(index_live, "#series-seasons")
      assert render(index_live) =~ "Season updated successfully"
    end

    test "deletes season in listing", %{conn: conn, series: series, season: season} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/series/#{series}/seasons")

      assert index_live
             |> element("#series_seasons-#{season.id} a", "Delete")
             |> render_click()

      refute has_element?(index_live, "#series_seasons-#{season.id}")
    end
  end

  describe "Show" do
    setup [:create_series_season]

    test "displays season", %{conn: conn, series: series, season: season} do
      {:ok, show_live, _html} = live(conn, ~p"/admin/series/#{series}/seasons/#{season}")

      assert has_element?(show_live, "#season-overview")
      assert has_element?(show_live, "#season-series")
      assert has_element?(show_live, "#season-actions")
      assert has_element?(show_live, "#season-events-entry")
      assert has_element?(show_live, "#season-events-action")
    end

    test "updates season and returns to show", %{conn: conn, series: series, season: season} do
      {:ok, show_live, _html} = live(conn, ~p"/admin/series/#{series}/seasons/#{season}")

      assert {:ok, form_live, _} =
               show_live
               |> element("#season-edit-action")
               |> render_click()
               |> follow_redirect(
                 conn,
                 ~p"/admin/series/#{series}/seasons/#{season}/edit?return_to=show"
               )

      assert has_element?(form_live, "#series-season-form")

      assert {:ok, show_live, _html} =
               form_live
               |> form("#series-season-form", season: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/admin/series/#{series}/seasons/#{season}")

      assert has_element?(show_live, "#season-overview")
      assert has_element?(show_live, "#season-actions")
      assert has_element?(show_live, "#season-series")
      assert has_element?(show_live, "#season-events-entry")
    end
  end
end
