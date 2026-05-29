defmodule SlipstreamWeb.SeriesSourceLiveTest do
  use SlipstreamWeb.ConnCase

  import Phoenix.LiveViewTest
  import Slipstream.MotorsportFixtures

  @create_attrs %{
    name: "Official calendar",
    priority: 1,
    format: "html",
    url: "https://example.com/new-calendar",
    source_type: "calendar",
    http_method: "GET",
    request_headers_json: ~s({"accept": "text/html"}),
    request_params_json: ~s({"season": "2026"}),
    extraction_config_json: ~s({"item_selector": ".race-card"}),
    is_active: true,
    notes: "some notes"
  }

  @update_attrs %{
    name: "Updated results",
    priority: 2,
    format: "json",
    url: "https://example.com/results",
    source_type: "results",
    http_method: "POST",
    request_headers_json: ~s({"accept": "application/json"}),
    request_params_json: "{}",
    extraction_config_json: ~s({"items_path": "data.races"}),
    is_active: false,
    notes: "some updated notes"
  }

  @invalid_attrs %{
    name: nil,
    priority: nil,
    format: "html",
    url: nil,
    source_type: "calendar",
    http_method: "GET",
    extraction_config_json: "not json",
    is_active: false
  }

  defp create_series_source(_) do
    series = series_fixture()
    series_source = series_source_fixture(series: series)

    %{series: series, series_source: series_source}
  end

  describe "Index" do
    setup [:create_series_source]

    test "lists all series_sources for a series", %{
      conn: conn,
      series: series,
      series_source: series_source
    } do
      {:ok, index_live, _html} = live(conn, ~p"/admin/series/#{series}/sources")

      assert has_element?(index_live, "#series_sources-#{series_source.id}")
    end

    test "saves new series_source", %{conn: conn, series: series} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/series/#{series}/sources")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Source")
               |> render_click()
               |> follow_redirect(conn, ~p"/admin/series/#{series}/sources/new")

      assert has_element?(form_live, "#series-source-form")

      assert form_live
             |> form("#series-source-form", series_source: @invalid_attrs)
             |> render_change() =~ "must be valid JSON"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#series-source-form", series_source: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/admin/series/#{series}/sources")

      assert has_element?(index_live, "#series-sources")
      assert render(index_live) =~ "Source created successfully"
    end

    test "updates series_source in listing", %{
      conn: conn,
      series: series,
      series_source: series_source
    } do
      {:ok, index_live, _html} = live(conn, ~p"/admin/series/#{series}/sources")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#series_sources-#{series_source.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/admin/series/#{series}/sources/#{series_source}/edit")

      assert has_element?(form_live, "#series-source-form")

      assert {:ok, index_live, _html} =
               form_live
               |> form("#series-source-form", series_source: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/admin/series/#{series}/sources")

      assert has_element?(index_live, "#series-sources")
      assert render(index_live) =~ "Source updated successfully"
    end

    test "deletes series_source in listing", %{
      conn: conn,
      series: series,
      series_source: series_source
    } do
      {:ok, index_live, _html} = live(conn, ~p"/admin/series/#{series}/sources")

      assert index_live
             |> element("#series_sources-#{series_source.id} a", "Delete")
             |> render_click()

      refute has_element?(index_live, "#series_sources-#{series_source.id}")
    end
  end

  describe "Show" do
    setup [:create_series_source]

    test "displays series_source", %{conn: conn, series: series, series_source: series_source} do
      {:ok, show_live, _html} = live(conn, ~p"/admin/series/#{series}/sources/#{series_source}")

      assert has_element?(show_live, "h1")
    end

    test "updates series_source and returns to show", %{
      conn: conn,
      series: series,
      series_source: series_source
    } do
      {:ok, show_live, _html} = live(conn, ~p"/admin/series/#{series}/sources/#{series_source}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit Source")
               |> render_click()
               |> follow_redirect(
                 conn,
                 ~p"/admin/series/#{series}/sources/#{series_source}/edit?return_to=show"
               )

      assert has_element?(form_live, "#series-source-form")

      assert {:ok, show_live, _html} =
               form_live
               |> form("#series-source-form", series_source: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/admin/series/#{series}/sources/#{series_source}")

      assert has_element?(show_live, "h1")
      assert render(show_live) =~ "Source updated successfully"
    end
  end
end
