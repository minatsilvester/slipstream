defmodule SlipstreamWeb.SeriesLive.Index do
  use SlipstreamWeb, :live_view

  alias Slipstream.Motorsport

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Listing Series
        <:actions>
          <.button variant="primary" navigate={~p"/admin/series/new"}>
            <.icon name="hero-plus" /> New Series
          </.button>
        </:actions>
      </.header>

      <.table
        id="series"
        rows={@streams.series_collection}
        row_click={fn {_id, series} -> JS.navigate(~p"/admin/series/#{series}") end}
      >
        <:col :let={{_id, series}} label="Name">{series.name}</:col>
        <:col :let={{_id, series}} label="Short name">{series.short_name}</:col>
        <:col :let={{_id, series}} label="Description">{series.description}</:col>
        <:col :let={{_id, series}} label="Sport type">{series.sport_type}</:col>
        <:col :let={{_id, series}} label="Governing body">{series.governing_body}</:col>
        <:col :let={{_id, series}} label="Logo url">{series.logo_url}</:col>
        <:col :let={{_id, series}} label="Official website">{series.official_website}</:col>
        <:col :let={{_id, series}} label="Is active">{series.is_active}</:col>
        <:col :let={{_id, series}} label="Metadata">{inspect(series.metadata)}</:col>
        <:action :let={{_id, series}}>
          <div class="sr-only">
            <.link navigate={~p"/admin/series/#{series}"}>Show</.link>
          </div>
          <.link navigate={~p"/admin/series/#{series}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, series}}>
          <.link
            phx-click={JS.push("delete", value: %{id: series.id}) |> hide("##{id}")}
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
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Listing Series")
     |> stream(:series_collection, list_series())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    series = Motorsport.get_series!(id)
    {:ok, _} = Motorsport.delete_series(series)

    {:noreply, stream_delete(socket, :series_collection, series)}
  end

  defp list_series() do
    Motorsport.list_series()
  end
end
