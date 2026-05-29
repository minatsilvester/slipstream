defmodule SlipstreamWeb.SeriesSourceLive.Show do
  use SlipstreamWeb, :live_view

  alias Slipstream.Motorsport

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@source.name}
        <:subtitle>{@series.name} source configuration.</:subtitle>
        <:actions>
          <.button navigate={~p"/admin/series/#{@series}/sources"}>
            <.icon name="hero-arrow-left" /> Sources
          </.button>
          <.button
            variant="primary"
            navigate={~p"/admin/series/#{@series}/sources/#{@source}/edit?return_to=show"}
          >
            <.icon name="hero-pencil-square" /> Edit Source
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="URL">{@source.url}</:item>
        <:item title="Source type">{@source.source_type}</:item>
        <:item title="Format">{@source.format}</:item>
        <:item title="HTTP method">{@source.http_method}</:item>
        <:item title="Priority">{@source.priority}</:item>
        <:item title="Active">{@source.is_active}</:item>
        <:item title="Request headers">{inspect(@source.request_headers)}</:item>
        <:item title="Request params">{inspect(@source.request_params)}</:item>
        <:item title="Extraction config">{inspect(@source.extraction_config)}</:item>
        <:item title="Notes">{@source.notes}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"series_id" => series_id, "id" => id}, _session, socket) do
    series = Motorsport.get_series!(series_id)
    source = Motorsport.get_series_source!(series, id)

    {:ok,
     socket
     |> assign(:page_title, "Show Source")
     |> assign(:series, series)
     |> assign(:source, source)}
  end
end
