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
            id="season-sync-action"
            phx-click="sync_calendar"
            disabled={@sync_status == :processing}
          >
            <.icon name="hero-arrow-path" /> Sync calendar
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

          <div
            id="season-sync-status"
            class="mt-6 rounded-box border border-base-300 bg-base-200/40 p-4"
          >
            <div class="flex items-center justify-between gap-4">
              <div>
                <p class="text-xs font-semibold uppercase tracking-[0.18em] text-base-content/60">
                  Calendar sync
                </p>
                <p class="mt-1 text-sm text-base-content/70">
                  {sync_status_label(@sync_status)}
                </p>
              </div>

              <span class={["badge", sync_badge_class(@sync_status)]}>
                {sync_status_label(@sync_status)}
              </span>
            </div>

            <p :if={@sync_entries != []} class="mt-4 text-sm text-base-content/80">
              Parsed entries: {@sync_entries_count}
            </p>

            <p :if={@sync_error} class="mt-3 text-sm text-error">
              {@sync_error}
            </p>
          </div>
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

          <section id="season-events-entry" class="rounded-box border border-base-300 bg-base-100 p-5">
            <p class="text-xs font-semibold uppercase tracking-[0.2em] text-base-content/60">
              Events
            </p>
            <p class="mt-3 text-sm text-base-content/70">
              Review rounds imported from the scraper and correct postponed or cancelled sessions.
            </p>
            <div class="mt-4">
              <.button
                id="season-events-action"
                variant="primary"
                navigate={~p"/admin/series/#{@series}/seasons/#{@season}/events"}
              >
                <.icon name="hero-calendar-days" /> Manage events
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

    if connected?(socket) do
      Phoenix.PubSub.subscribe(
        Slipstream.PubSub,
        Slipstream.Ingestion.Formula1CalendarSync.topic(season.id)
      )
    end

    {:ok,
     socket
     |> assign(:page_title, "Show Season")
     |> assign(:series, series)
     |> assign(:season, season)
     |> assign(:sync_status, :idle)
     |> assign(:sync_entries, [])
     |> assign(:sync_entries_count, 0)
     |> assign(:sync_error, nil)}
  end

  @impl true
  def handle_event("sync_calendar", _params, socket) do
    case Motorsport.sync_season_calendar(socket.assigns.season) do
      {:ok, _pid} ->
        {:noreply,
         socket
         |> assign(:sync_status, :processing)
         |> assign(:sync_entries, [])
         |> assign(:sync_entries_count, 0)
         |> assign(:sync_error, nil)}

      {:error, {:already_started, _pid}} ->
        {:noreply, put_flash(socket, :info, "Calendar sync is already running")}

      {:error, reason} ->
        {:noreply,
         socket
         |> assign(:sync_status, :failed)
         |> assign(:sync_error, inspect(reason))}
    end
  end

  @impl true
  def handle_info({:formula1_calendar_sync, payload}, socket) do
    socket =
      case payload.status do
        :processing ->
          socket
          |> assign(:sync_status, :processing)
          |> assign(:sync_error, nil)

        :done ->
          socket
          |> assign(:sync_status, :done)
          |> assign(:sync_entries, payload.entries || [])
          |> assign(:sync_entries_count, length(payload.entries || []))
          |> assign(:sync_error, nil)

        :failed ->
          socket
          |> assign(:sync_status, :failed)
          |> assign(:sync_error, payload.error)

        _ ->
          socket
      end

    {:noreply, socket}
  end

  defp format_date(nil), do: "Not set"
  defp format_date(date), do: Calendar.strftime(date, "%Y-%m-%d")

  defp sync_status_label(:idle), do: "Idle"
  defp sync_status_label(:processing), do: "Processing"
  defp sync_status_label(:done), do: "Complete"
  defp sync_status_label(:failed), do: "Failed"

  defp sync_badge_class(:idle), do: "badge-ghost"
  defp sync_badge_class(:processing), do: "badge-warning"
  defp sync_badge_class(:done), do: "badge-success"
  defp sync_badge_class(:failed), do: "badge-error"
end
