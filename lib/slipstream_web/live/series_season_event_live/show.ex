defmodule SlipstreamWeb.SeriesSeasonEventLive.Show do
  use SlipstreamWeb, :live_view

  alias Slipstream.Motorsport

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@event.name}
        <:subtitle>Round {@event.round} in {@season.year}.</:subtitle>
        <:actions>
          <.button navigate={~p"/admin/series/#{@series}/seasons/#{@season}/events"}>
            <.icon name="hero-arrow-left" /> Events
          </.button>
          <.button
            variant="primary"
            navigate={
              ~p"/admin/series/#{@series}/seasons/#{@season}/events/#{@event}/edit?return_to=show"
            }
          >
            <.icon name="hero-pencil-square" /> Edit event
          </.button>
        </:actions>
      </.header>

      <div class="grid gap-6 xl:grid-cols-[minmax(0,1.4fr)_minmax(18rem,0.8fr)]">
        <section id="event-overview" class="rounded-box border border-base-300 bg-base-100 p-5">
          <dl class="grid gap-4 sm:grid-cols-2">
            <div class="rounded-box border border-base-300 bg-base-200/40 p-4">
              <dt class="text-xs font-semibold uppercase tracking-[0.18em] text-base-content/60">
                Round
              </dt>
              <dd class="mt-2 text-2xl font-semibold">{@event.round}</dd>
            </div>
            <div class="rounded-box border border-base-300 bg-base-200/40 p-4">
              <dt class="text-xs font-semibold uppercase tracking-[0.18em] text-base-content/60">
                Status
              </dt>
              <dd class="mt-2 text-base font-medium">{@event.status}</dd>
            </div>
            <div class="rounded-box border border-base-300 bg-base-200/40 p-4">
              <dt class="text-xs font-semibold uppercase tracking-[0.18em] text-base-content/60">
                Starts on
              </dt>
              <dd class="mt-2 text-base font-medium">{format_date(@event.starts_on)}</dd>
            </div>
            <div class="rounded-box border border-base-300 bg-base-200/40 p-4">
              <dt class="text-xs font-semibold uppercase tracking-[0.18em] text-base-content/60">
                Ends on
              </dt>
              <dd class="mt-2 text-base font-medium">{format_date(@event.ends_on)}</dd>
            </div>
          </dl>
        </section>

        <aside class="space-y-6">
          <section id="event-meta" class="rounded-box border border-base-300 bg-base-100 p-5">
            <p class="text-xs font-semibold uppercase tracking-[0.2em] text-base-content/60">
              Location
            </p>
            <p class="mt-3 text-base font-medium">{@event.venue_name || "Not set"}</p>
            <p class="mt-1 text-sm text-base-content/70">{@event.location || "Not set"}</p>
            <p class="mt-1 text-sm text-base-content/70">{@event.country || "Not set"}</p>
          </section>
          <section id="event-sessions" class="rounded-box border border-base-300 bg-base-100 p-5">
            <p class="text-xs font-semibold uppercase tracking-[0.2em] text-base-content/60">
              Sessions
            </p>
            <pre class="mt-3 overflow-auto rounded-box bg-base-200/60 p-4 text-xs"><%= Jason.encode!(@event.sessions || %{}, pretty: true) %></pre>
          </section>
        </aside>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"series_id" => series_id, "season_id" => season_id, "id" => id}, _session, socket) do
    series = Motorsport.get_series!(series_id)
    season = Motorsport.get_season!(series, season_id)
    event = Motorsport.get_event!(season, id)

    {:ok,
     socket
     |> assign(:page_title, "Show Event")
     |> assign(:series, series)
     |> assign(:season, season)
     |> assign(:event, event)}
  end

  defp format_date(nil), do: "Not set"
  defp format_date(date), do: Calendar.strftime(date, "%Y-%m-%d")
end
