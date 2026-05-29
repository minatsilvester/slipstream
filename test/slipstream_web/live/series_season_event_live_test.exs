defmodule SlipstreamWeb.SeriesSeasonEventLiveTest do
  use SlipstreamWeb.ConnCase

  import Phoenix.LiveViewTest
  import Slipstream.MotorsportFixtures

  @create_attrs %{
    round: 5,
    name: "Formula 1 Monaco Grand Prix",
    venue_name: "Circuit de Monaco",
    location: "Monte Carlo",
    country: "Monaco",
    starts_on: "2026-06-05",
    ends_on: "2026-06-07",
    timezone: "Europe/Monaco",
    status: "scheduled",
    sessions_json: ~s({"race":{"date":"2026-06-07"}})
  }

  @update_attrs %{
    round: 6,
    name: "Formula 1 Monaco Grand Prix Updated",
    venue_name: "Circuit de Monaco",
    location: "Monte Carlo",
    country: "Monaco",
    starts_on: "2026-06-06",
    ends_on: "2026-06-08",
    timezone: "Europe/Monaco",
    status: "postponed",
    sessions_json: ~s({"race":{"date":"2026-06-08"}})
  }

  @invalid_attrs %{
    round: nil,
    name: nil,
    status: "scheduled"
  }

  defp create_series_season_event(_) do
    series = series_fixture()
    season = season_fixture(series: series)
    event = event_fixture(season: season)

    %{series: series, season: season, event: event}
  end

  describe "Index" do
    setup [:create_series_season_event]

    test "lists all events for a season", %{
      conn: conn,
      series: series,
      season: season,
      event: event
    } do
      {:ok, index_live, _html} = live(conn, ~p"/admin/series/#{series}/seasons/#{season}/events")

      assert has_element?(index_live, "#season-events")
      assert has_element?(index_live, "#season_events-#{event.id}")
    end

    test "saves new event", %{conn: conn, series: series, season: season} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/series/#{series}/seasons/#{season}/events")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Event")
               |> render_click()
               |> follow_redirect(conn, ~p"/admin/series/#{series}/seasons/#{season}/events/new")

      assert has_element?(form_live, "#season-event-form")

      assert form_live
             |> form("#season-event-form", event: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#season-event-form", event: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/admin/series/#{series}/seasons/#{season}/events")

      assert has_element?(index_live, "#season-events")
      assert render(index_live) =~ "Event created successfully"
    end

    test "updates event in listing", %{conn: conn, series: series, season: season, event: event} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/series/#{series}/seasons/#{season}/events")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#season_events-#{event.id} a", "Edit")
               |> render_click()
               |> follow_redirect(
                 conn,
                 ~p"/admin/series/#{series}/seasons/#{season}/events/#{event}/edit"
               )

      assert has_element?(form_live, "#season-event-form")

      assert {:ok, index_live, _html} =
               form_live
               |> form("#season-event-form", event: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/admin/series/#{series}/seasons/#{season}/events")

      assert has_element?(index_live, "#season-events")
      assert render(index_live) =~ "Event updated successfully"
    end

    test "deletes event in listing", %{conn: conn, series: series, season: season, event: event} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/series/#{series}/seasons/#{season}/events")

      assert index_live
             |> element("#season_events-#{event.id} a", "Delete")
             |> render_click()

      refute has_element?(index_live, "#season_events-#{event.id}")
    end
  end

  describe "Show" do
    setup [:create_series_season_event]

    test "displays event", %{conn: conn, series: series, season: season, event: event} do
      {:ok, show_live, _html} =
        live(conn, ~p"/admin/series/#{series}/seasons/#{season}/events/#{event}")

      assert has_element?(show_live, "#event-overview")
      assert has_element?(show_live, "#event-meta")
      assert has_element?(show_live, "#event-sessions")
    end

    test "updates event and returns to show", %{
      conn: conn,
      series: series,
      season: season,
      event: event
    } do
      {:ok, show_live, _html} =
        live(conn, ~p"/admin/series/#{series}/seasons/#{season}/events/#{event}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit event")
               |> render_click()
               |> follow_redirect(
                 conn,
                 ~p"/admin/series/#{series}/seasons/#{season}/events/#{event}/edit?return_to=show"
               )

      assert has_element?(form_live, "#season-event-form")

      assert {:ok, show_live, _html} =
               form_live
               |> form("#season-event-form", event: @update_attrs)
               |> render_submit()
               |> follow_redirect(
                 conn,
                 ~p"/admin/series/#{series}/seasons/#{season}/events/#{event}"
               )

      assert has_element?(show_live, "#event-overview")
      assert has_element?(show_live, "#event-meta")
      assert has_element?(show_live, "#event-sessions")
    end
  end
end
