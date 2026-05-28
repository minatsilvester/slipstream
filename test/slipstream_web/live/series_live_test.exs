defmodule SlipstreamWeb.SeriesLiveTest do
  use SlipstreamWeb.ConnCase

  import Phoenix.LiveViewTest
  import Slipstream.MotorsportFixtures

  @create_attrs %{name: "some name", description: "some description", metadata: %{}, short_name: "some short_name", sport_type: "some sport_type", governing_body: "some governing_body", logo_url: "some logo_url", official_website: "some official_website", is_active: true}
  @update_attrs %{name: "some updated name", description: "some updated description", metadata: %{}, short_name: "some updated short_name", sport_type: "some updated sport_type", governing_body: "some updated governing_body", logo_url: "some updated logo_url", official_website: "some updated official_website", is_active: false}
  @invalid_attrs %{name: nil, description: nil, metadata: nil, short_name: nil, sport_type: nil, governing_body: nil, logo_url: nil, official_website: nil, is_active: false}
  defp create_series(_) do
    series = series_fixture()

    %{series: series}
  end

  describe "Index" do
    setup [:create_series]

    test "lists all series", %{conn: conn, series: series} do
      {:ok, _index_live, html} = live(conn, ~p"/series")

      assert html =~ "Listing Series"
      assert html =~ series.name
    end

    test "saves new series", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/series")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Series")
               |> render_click()
               |> follow_redirect(conn, ~p"/admin/seriesnew")

      assert render(form_live) =~ "New Series"

      assert form_live
             |> form("#series-form", series: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#series-form", series: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/series")

      html = render(index_live)
      assert html =~ "Series created successfully"
      assert html =~ "some name"
    end

    test "updates series in listing", %{conn: conn, series: series} do
      {:ok, index_live, _html} = live(conn, ~p"/series")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#series_collection-#{series.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/admin/series#{series}/edit")

      assert render(form_live) =~ "Edit Series"

      assert form_live
             |> form("#series-form", series: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#series-form", series: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/series")

      html = render(index_live)
      assert html =~ "Series updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes series in listing", %{conn: conn, series: series} do
      {:ok, index_live, _html} = live(conn, ~p"/series")

      assert index_live |> element("#series_collection-#{series.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#series-#{series.id}")
    end
  end

  describe "Show" do
    setup [:create_series]

    test "displays series", %{conn: conn, series: series} do
      {:ok, _show_live, html} = live(conn, ~p"/admin/series#{series}")

      assert html =~ "Show Series"
      assert html =~ series.name
    end

    test "updates series and returns to show", %{conn: conn, series: series} do
      {:ok, show_live, _html} = live(conn, ~p"/admin/series#{series}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/admin/series#{series}/edit?return_to=show")

      assert render(form_live) =~ "Edit Series"

      assert form_live
             |> form("#series-form", series: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#series-form", series: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/admin/series#{series}")

      html = render(show_live)
      assert html =~ "Series updated successfully"
      assert html =~ "some updated name"
    end
  end
end
