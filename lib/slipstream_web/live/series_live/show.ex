defmodule SlipstreamWeb.SeriesLive.Show do
  use SlipstreamWeb, :live_view

  alias Slipstream.Motorsport

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Series {@series.id}
        <:subtitle>This is a series record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/admin/series"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button navigate={~p"/admin/series/#{@series}/sources"}>
            <.icon name="hero-rss" /> Sources
          </.button>
          <.button variant="primary" navigate={~p"/admin/series/#{@series}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit series
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Name">{@series.name}</:item>
        <:item title="Short name">{@series.short_name}</:item>
        <:item title="Description">{@series.description}</:item>
        <:item title="Sport type">{@series.sport_type}</:item>
        <:item title="Governing body">{@series.governing_body}</:item>
        <:item title="Logo url">{@series.logo_url}</:item>
        <:item title="Official website">{@series.official_website}</:item>
        <:item title="Is active">{@series.is_active}</:item>
        <:item title="Metadata">{inspect(@series.metadata)}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Series")
     |> assign(:series, Motorsport.get_series!(id))}
  end
end
