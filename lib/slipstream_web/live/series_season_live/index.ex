defmodule SlipstreamWeb.SeriesSeasonLive.Index do
  use SlipstreamWeb, :live_view

  alias Slipstream.Motorsport

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Seasons for {@series.name}
        <:subtitle>Track each calendar year before events are imported.</:subtitle>
        <:actions>
          <.button navigate={~p"/admin/series/#{@series}"}>
            <.icon name="hero-arrow-left" /> Series
          </.button>
          <.button variant="primary" navigate={~p"/admin/series/#{@series}/seasons/new"}>
            <.icon name="hero-plus" /> New Season
          </.button>
        </:actions>
      </.header>

      <.table
        id="series-seasons"
        rows={@streams.series_seasons}
        row_click={
          fn {_id, season} -> JS.navigate(~p"/admin/series/#{@series}/seasons/#{season}") end
        }
      >
        <:col :let={{_id, season}} label="Year">{season.year}</:col>
        <:col :let={{_id, season}} label="Current">
          <span class={["badge", (season.is_current && "badge-success") || "badge-ghost"]}>
            {(season.is_current && "Current") || "Archived"}
          </span>
        </:col>
        <:col :let={{_id, season}} label="Starts on">{format_date(season.starts_on)}</:col>
        <:col :let={{_id, season}} label="Ends on">{format_date(season.ends_on)}</:col>
        <:action :let={{_id, season}}>
          <div class="sr-only">
            <.link navigate={~p"/admin/series/#{@series}/seasons/#{season}"}>Show</.link>
          </div>
          <.link navigate={~p"/admin/series/#{@series}/seasons/#{season}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, season}}>
          <.link
            phx-click={JS.push("delete", value: %{id: season.id}) |> hide("##{id}")}
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
  def mount(%{"series_id" => series_id}, _session, socket) do
    series = Motorsport.get_series!(series_id)
    seasons = Motorsport.list_seasons(series)

    {:ok,
     socket
     |> assign(:page_title, "Series Seasons")
     |> assign(:series, series)
     |> assign(:seasons_empty?, seasons == [])
     |> stream(:series_seasons, seasons)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    season = Motorsport.get_season!(socket.assigns.series, id)
    {:ok, _} = Motorsport.delete_season(season)

    {:noreply, stream_delete(socket, :series_seasons, season)}
  end

  defp format_date(nil), do: "Not set"
  defp format_date(date), do: Calendar.strftime(date, "%Y-%m-%d")
end
