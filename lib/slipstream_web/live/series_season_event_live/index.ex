defmodule SlipstreamWeb.SeriesSeasonEventLive.Index do
  use SlipstreamWeb, :live_view

  alias Slipstream.Motorsport

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Events for Season {@season.year}
        <:subtitle>Canonical rounds for this season.</:subtitle>
        <:actions>
          <.button navigate={~p"/admin/series/#{@series}/seasons/#{@season}"}>
            <.icon name="hero-arrow-left" /> Season
          </.button>
          <.button
            variant="primary"
            navigate={~p"/admin/series/#{@series}/seasons/#{@season}/events/new"}
          >
            <.icon name="hero-plus" /> New Event
          </.button>
        </:actions>
      </.header>

      <.table
        id="season-events"
        rows={@streams.season_events}
        row_click={
          fn {_id, event} ->
            JS.navigate(~p"/admin/series/#{@series}/seasons/#{@season}/events/#{event}")
          end
        }
      >
        <:col :let={{_id, event}} label="Round">{event.round}</:col>
        <:col :let={{_id, event}} label="Name">{event.name}</:col>
        <:col :let={{_id, event}} label="Status">
          <span class={["badge", status_badge_class(event.status)]}>{event.status}</span>
        </:col>
        <:col :let={{_id, event}} label="Starts on">{format_date(event.starts_on)}</:col>
        <:col :let={{_id, event}} label="Ends on">{format_date(event.ends_on)}</:col>
        <:action :let={{_id, event}}>
          <div class="sr-only">
            <.link navigate={~p"/admin/series/#{@series}/seasons/#{@season}/events/#{event}"}>
              Show
            </.link>
          </div>
          <.link navigate={~p"/admin/series/#{@series}/seasons/#{@season}/events/#{event}/edit"}>
            Edit
          </.link>
        </:action>
        <:action :let={{id, event}}>
          <.link
            phx-click={JS.push("delete", value: %{id: event.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"series_id" => series_id, "season_id" => season_id}, _session, socket) do
    series = Motorsport.get_series!(series_id)
    season = Motorsport.get_season!(series, season_id)
    events = Motorsport.list_events(season)

    {:ok,
     socket
     |> assign(:page_title, "Season Events")
     |> assign(:series, series)
     |> assign(:season, season)
     |> assign(:events_empty?, events == [])
     |> stream(:season_events, events)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    event = Motorsport.get_event!(socket.assigns.season, id)
    {:ok, _} = Motorsport.delete_event(event)

    {:noreply, stream_delete(socket, :season_events, event)}
  end

  defp format_date(nil), do: "Not set"
  defp format_date(date), do: Calendar.strftime(date, "%Y-%m-%d")

  defp status_badge_class("scheduled"), do: "badge-success"
  defp status_badge_class("postponed"), do: "badge-warning"
  defp status_badge_class("cancelled"), do: "badge-error"
  defp status_badge_class("rescheduled"), do: "badge-info"
  defp status_badge_class(_), do: "badge-ghost"
end
