defmodule SlipstreamWeb.SeriesSourceLive.Index do
  use SlipstreamWeb, :live_view

  alias Slipstream.Motorsport

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Sources for {@series.name}
        <:subtitle>Configure the official feeds and webpages used to ingest this series.</:subtitle>
        <:actions>
          <.button navigate={~p"/admin/series/#{@series}"}>
            <.icon name="hero-arrow-left" /> Series
          </.button>
          <.button variant="primary" navigate={~p"/admin/series/#{@series}/sources/new"}>
            <.icon name="hero-plus" /> New Source
          </.button>
        </:actions>
      </.header>

      <.table
        id="series-sources"
        rows={@streams.series_sources}
        row_click={
          fn {_id, source} -> JS.navigate(~p"/admin/series/#{@series}/sources/#{source}") end
        }
      >
        <:col :let={{_id, source}} label="Name">{source.name}</:col>
        <:col :let={{_id, source}} label="Type">{source.source_type}</:col>
        <:col :let={{_id, source}} label="Format">{source.format}</:col>
        <:col :let={{_id, source}} label="Method">{source.http_method}</:col>
        <:col :let={{_id, source}} label="Priority">{source.priority}</:col>
        <:col :let={{_id, source}} label="Active">{source.is_active}</:col>
        <:action :let={{_id, source}}>
          <div class="sr-only">
            <.link navigate={~p"/admin/series/#{@series}/sources/#{source}"}>Show</.link>
          </div>
          <.link navigate={~p"/admin/series/#{@series}/sources/#{source}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, source}}>
          <.link
            phx-click={JS.push("delete", value: %{id: source.id}) |> hide("##{id}")}
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

    {:ok,
     socket
     |> assign(:page_title, "Series Sources")
     |> assign(:series, series)
     |> stream(:series_sources, Motorsport.list_series_sources(series))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    source = Motorsport.get_series_source!(socket.assigns.series, id)
    {:ok, _} = Motorsport.delete_series_source(source)

    {:noreply, stream_delete(socket, :series_sources, source)}
  end
end
