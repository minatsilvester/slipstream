defmodule SlipstreamWeb.SeriesSeasonLive.Show do
  use SlipstreamWeb, :live_view

  alias Slipstream.Motorsport

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Season {@season.year}
        <:subtitle>{@series.name} calendar container.</:subtitle>
        <:actions>
          <.button navigate={~p"/admin/series/#{@series}/seasons"}>
            <.icon name="hero-arrow-left" /> Seasons
          </.button>
          <.button
            variant="primary"
            navigate={~p"/admin/series/#{@series}/seasons/#{@season}/edit?return_to=show"}
          >
            <.icon name="hero-pencil-square" /> Edit season
          </.button>
        </:actions>
      </.header>

      <div class="grid gap-6 xl:grid-cols-[minmax(0,1.4fr)_minmax(18rem,0.8fr)]">
        <section id="season-overview" class="rounded-box border border-base-300 bg-base-100 p-5">
          <div class="flex items-start justify-between gap-4">
            <div>
              <p class="text-xs font-semibold uppercase tracking-[0.2em] text-base-content/60">
                Overview
              </p>
              <h2 class="mt-1 text-lg font-semibold text-base-content">
                Calendar window
              </h2>
            </div>

            <span class={["badge badge-lg", (@season.is_current && "badge-success") || "badge-ghost"]}>
              {(@season.is_current && "Current") || "Archived"}
            </span>
          </div>

          <dl class="mt-6 grid gap-4 sm:grid-cols-2">
            <div class="rounded-box border border-base-300 bg-base-200/40 p-4">
              <dt class="text-xs font-semibold uppercase tracking-[0.18em] text-base-content/60">
                Year
              </dt>
              <dd id="season-year" class="mt-2 text-2xl font-semibold">{@season.year}</dd>
            </div>

            <div class="rounded-box border border-base-300 bg-base-200/40 p-4">
              <dt class="text-xs font-semibold uppercase tracking-[0.18em] text-base-content/60">
                Current
              </dt>
              <dd id="season-current" class="mt-2 text-base font-medium">
                {(@season.is_current && "Yes") || "No"}
              </dd>
            </div>

            <div class="rounded-box border border-base-300 bg-base-200/40 p-4">
              <dt class="text-xs font-semibold uppercase tracking-[0.18em] text-base-content/60">
                Starts on
              </dt>
              <dd id="season-starts-on" class="mt-2 text-base font-medium">
                {format_date(@season.starts_on)}
              </dd>
            </div>

            <div class="rounded-box border border-base-300 bg-base-200/40 p-4">
              <dt class="text-xs font-semibold uppercase tracking-[0.18em] text-base-content/60">
                Ends on
              </dt>
              <dd id="season-ends-on" class="mt-2 text-base font-medium">
                {format_date(@season.ends_on)}
              </dd>
            </div>
          </dl>
        </section>

        <aside class="space-y-6">
          <section id="season-series" class="rounded-box border border-base-300 bg-base-100 p-5">
            <p class="text-xs font-semibold uppercase tracking-[0.2em] text-base-content/60">
              Series
            </p>
            <p class="mt-3 text-base font-medium">{@series.name}</p>
            <p class="mt-1 text-sm text-base-content/70">{@series.short_name}</p>
          </section>

          <section id="season-actions" class="rounded-box border border-base-300 bg-base-100 p-5">
            <p class="text-xs font-semibold uppercase tracking-[0.2em] text-base-content/60">
              Actions
            </p>
            <div class="mt-4 grid gap-3">
              <.button
                id="season-edit-action"
                navigate={~p"/admin/series/#{@series}/seasons/#{@season}/edit?return_to=show"}
              >
                <.icon name="hero-pencil-square" /> Edit season
              </.button>
              <.button id="season-list-action" navigate={~p"/admin/series/#{@series}/seasons"}>
                <.icon name="hero-list-bullet" /> Season list
              </.button>
            </div>
          </section>
        </aside>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"series_id" => series_id, "id" => id}, _session, socket) do
    series = Motorsport.get_series!(series_id)
    season = Motorsport.get_season!(series, id)

    {:ok,
     socket
     |> assign(:page_title, "Show Season")
     |> assign(:series, series)
     |> assign(:season, season)}
  end

  defp format_date(nil), do: "Not set"
  defp format_date(date), do: Calendar.strftime(date, "%Y-%m-%d")
end
