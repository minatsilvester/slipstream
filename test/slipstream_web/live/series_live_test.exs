defmodule SlipstreamWeb.SeriesLiveTest do
  use SlipstreamWeb.ConnCase

  import Phoenix.LiveViewTest
  import Slipstream.MotorsportFixtures

  @create_attrs %{
    name: "some name",
    description: "some description",
    short_name: "some short_name",
    sport_type: "some sport_type",
    governing_body: "some governing_body",
    logo_url: "some logo_url",
    official_website: "some official_website",
    is_active: true
  }
  @update_attrs %{
    name: "some updated name",
    description: "some updated description",
    short_name: "some updated short_name",
    sport_type: "some updated sport_type",
    governing_body: "some updated governing_body",
    logo_url: "some updated logo_url",
    official_website: "some updated official_website",
    is_active: false
  }
  @invalid_attrs %{
    name: nil,
    description: nil,
    short_name: nil,
    sport_type: nil,
    governing_body: nil,
    logo_url: nil,
    official_website: nil,
    is_active: false
  }
  defp create_series(_) do
    series = series_fixture()

    %{series: series}
  end

  defp create_series_with_source(_) do
    series = series_fixture()
    series_source = series_source_fixture(series: series)
    season = season_fixture(series: series)

    %{series: series, series_source: series_source, season: season}
  end

  describe "Index" do
    setup [:create_series]

    test "lists all series", %{conn: conn, series: series} do
      {:ok, _index_live, html} = live(conn, ~p"/admin/series")

      assert html =~ "Listing Series"
      assert html =~ series.name
    end

    test "saves new series", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/series")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Series")
               |> render_click()
               |> follow_redirect(conn, ~p"/admin/series/new")

      assert render(form_live) =~ "New Series"

      assert form_live
             |> form("#series-form", series: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#series-form", series: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/admin/series")

      html = render(index_live)
      assert html =~ "Series created successfully"
      assert html =~ "some name"
    end

    test "updates series in listing", %{conn: conn, series: series} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/series")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#series_collection-#{series.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/admin/series/#{series}/edit")

      assert render(form_live) =~ "Edit Series"

      assert form_live
             |> form("#series-form", series: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#series-form", series: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/admin/series")

      html = render(index_live)
      assert html =~ "Series updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes series in listing", %{conn: conn, series: series} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/series")

      assert index_live
             |> element("#series_collection-#{series.id} a", "Delete")
             |> render_click()

      refute has_element?(index_live, "#series_collection-#{series.id}")
    end
  end

  describe "Show" do
    setup [:create_series_with_source]

    test "displays series", %{
      conn: conn,
      series: series,
      series_source: series_source,
      season: season
    } do
      {:ok, show_live, _html} = live(conn, ~p"/admin/series/#{series}")

      assert has_element?(show_live, "#series-overview")
      assert has_element?(show_live, "#series-links")
      assert has_element?(show_live, "#series-actions")
      assert has_element?(show_live, "#series-seasons-section")
      assert has_element?(show_live, "#series-sources-section")
      assert has_element?(show_live, "#series_seasons-#{season.id}")
      assert has_element?(show_live, "#series_sources-#{series_source.id}")
    end

    test "updates series and returns to show", %{conn: conn, series: series} do
      {:ok, show_live, _html} = live(conn, ~p"/admin/series/#{series}")

      assert {:ok, form_live, _} =
               show_live
               |> element("#series-edit-button")
               |> render_click()
               |> follow_redirect(conn, ~p"/admin/series/#{series}/edit?return_to=show")

      assert render(form_live) =~ "Edit Series"

      assert form_live
             |> form("#series-form", series: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#series-form", series: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/admin/series/#{series}")

      assert has_element?(show_live, "#series-overview")
      assert has_element?(show_live, "#series-actions")
      assert has_element?(show_live, "#series-seasons-section")
      assert has_element?(show_live, "#series-sources-section")
      assert has_element?(show_live, "#series-status")
    end
  end
end
