defmodule SlipstreamWeb.SeriesLive.Show do
  use SlipstreamWeb, :live_view

  alias Slipstream.Motorsport

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@series.name}
        <:subtitle>
          {@series.short_name} · {@series.sport_type} · {@series.governing_body}
        </:subtitle>
        <:actions>
          <.button id="series-back-button" navigate={~p"/admin/series"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button id="series-sources-button" navigate={~p"/admin/series/#{@series}/sources"}>
            <.icon name="hero-rss" /> Sources
          </.button>
          <.button
            id="series-edit-button"
            variant="primary"
            navigate={~p"/admin/series/#{@series}/edit?return_to=show"}
          >
            <.icon name="hero-pencil-square" /> Edit series
          </.button>
        </:actions>
      </.header>

      <div class="grid gap-6 xl:grid-cols-[minmax(0,1.4fr)_minmax(18rem,0.8fr)]">
        <section id="series-overview" class="rounded-box border border-base-300 bg-base-100 p-5">
          <div class="flex items-start justify-between gap-4">
            <div>
              <p class="text-xs font-semibold uppercase tracking-[0.2em] text-base-content/60">
                Overview
              </p>
              <h2 class="mt-1 text-lg font-semibold text-base-content">
                Series profile
              </h2>
            </div>

            <span
              id="series-status"
              class={[
                "badge badge-lg",
                (@series.is_active && "badge-success") || "badge-ghost"
              ]}
            >
              {(@series.is_active && "Active") || "Inactive"}
            </span>
          </div>

          <dl class="mt-6 grid gap-4 sm:grid-cols-2">
            <div class="rounded-box border border-base-300 bg-base-200/40 p-4">
              <dt class="text-xs font-semibold uppercase tracking-[0.18em] text-base-content/60">
                Short name
              </dt>
              <dd id="series-short-name" class="mt-2 break-words text-base font-medium">
                {@series.short_name}
              </dd>
            </div>

            <div class="rounded-box border border-base-300 bg-base-200/40 p-4">
              <dt class="text-xs font-semibold uppercase tracking-[0.18em] text-base-content/60">
                Sport type
              </dt>
              <dd id="series-sport-type" class="mt-2 break-words text-base font-medium">
                {@series.sport_type}
              </dd>
            </div>

            <div class="rounded-box border border-base-300 bg-base-200/40 p-4">
              <dt class="text-xs font-semibold uppercase tracking-[0.18em] text-base-content/60">
                Governing body
              </dt>
              <dd id="series-governing-body" class="mt-2 break-words text-base font-medium">
                {@series.governing_body}
              </dd>
            </div>

            <div class="rounded-box border border-base-300 bg-base-200/40 p-4">
              <dt class="text-xs font-semibold uppercase tracking-[0.18em] text-base-content/60">
                Source count
              </dt>
              <dd id="series-source-count" class="mt-2 text-3xl font-semibold tracking-tight">
                {@series_source_count}
              </dd>
            </div>
          </dl>

          <div class="mt-6 grid gap-4 md:grid-cols-2">
            <div>
              <h3 class="text-sm font-semibold text-base-content/70">Description</h3>
              <p id="series-description" class="mt-2 leading-6 text-base-content/80">
                {series_description(@series.description)}
              </p>
            </div>

            <div>
              <h3 class="text-sm font-semibold text-base-content/70">Metadata</h3>
              <pre
                id="series-metadata"
                class="mt-2 overflow-x-auto rounded-box border border-base-300 bg-base-200/60 p-4 text-sm leading-6 text-base-content/80"
              >{metadata_text(@series.metadata)}</pre>
            </div>
          </div>
        </section>

        <aside class="space-y-6">
          <section id="series-links" class="rounded-box border border-base-300 bg-base-100 p-5">
            <p class="text-xs font-semibold uppercase tracking-[0.2em] text-base-content/60">
              Quick access
            </p>

            <div class="mt-4 space-y-3 text-sm">
              <div class="flex items-center justify-between gap-4">
                <span class="text-base-content/60">Official website</span>
                <%= if @series.official_website do %>
                  <a
                    id="series-official-website"
                    href={@series.official_website}
                    target="_blank"
                    rel="noreferrer"
                    class="link link-primary truncate"
                  >
                    Open
                  </a>
                <% else %>
                  <span class="text-base-content/40">Not set</span>
                <% end %>
              </div>

              <div class="flex items-center justify-between gap-4">
                <span class="text-base-content/60">Logo URL</span>
                <%= if @series.logo_url do %>
                  <a
                    id="series-logo-url"
                    href={@series.logo_url}
                    target="_blank"
                    rel="noreferrer"
                    class="link link-primary truncate"
                  >
                    Open
                  </a>
                <% else %>
                  <span class="text-base-content/40">Not set</span>
                <% end %>
              </div>
            </div>
          </section>

          <section id="series-actions" class="rounded-box border border-base-300 bg-base-100 p-5">
            <p class="text-xs font-semibold uppercase tracking-[0.2em] text-base-content/60">
              Actions
            </p>

            <div class="mt-4 grid gap-3">
              <.button
                id="series-edit-action"
                navigate={~p"/admin/series/#{@series}/edit?return_to=show"}
              >
                <.icon name="hero-pencil-square" /> Edit series
              </.button>
              <.button
                id="series-manage-sources-action"
                navigate={~p"/admin/series/#{@series}/sources"}
              >
                <.icon name="hero-rss" /> Manage sources
              </.button>
              <.button
                id="series-manage-seasons-action"
                navigate={~p"/admin/series/#{@series}/seasons"}
              >
                <.icon name="hero-calendar-days" /> Manage seasons
              </.button>
              <.button
                id="series-add-source-action"
                navigate={~p"/admin/series/#{@series}/sources/new"}
              >
                <.icon name="hero-plus" /> Add source
              </.button>
            </div>
          </section>
        </aside>
      </div>

      <section
        id="series-seasons-section"
        class="mt-6 rounded-box border border-base-300 bg-base-100 p-5"
      >
        <div class="flex flex-wrap items-center justify-between gap-4">
          <div>
            <p class="text-xs font-semibold uppercase tracking-[0.2em] text-base-content/60">
              Seasons
            </p>
            <h2 class="mt-1 text-lg font-semibold text-base-content">
              Calendar years
            </h2>
          </div>

          <.button navigate={~p"/admin/series/#{@series}/seasons/new"}>
            <.icon name="hero-plus" /> New season
          </.button>
        </div>

        <%= if @series_seasons_empty? do %>
          <div
            id="series-seasons-empty"
            class="mt-6 rounded-box border border-dashed border-base-300 bg-base-200/40 px-5 py-8 text-center"
          >
            <p class="font-medium text-base-content">No seasons have been created yet.</p>
            <p class="mt-2 text-sm text-base-content/70">
              Add a season for the current calendar year before importing events.
            </p>
            <div class="mt-5">
              <.button variant="primary" navigate={~p"/admin/series/#{@series}/seasons/new"}>
                <.icon name="hero-plus" /> Add season
              </.button>
            </div>
          </div>
        <% else %>
          <div class="mt-5 overflow-x-auto">
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
                <.link navigate={~p"/admin/series/#{@series}/seasons/#{season}/edit"}>
                  Edit
                </.link>
              </:action>
            </.table>
          </div>
        <% end %>
      </section>

      <section
        id="series-sources-section"
        class="mt-6 rounded-box border border-base-300 bg-base-100 p-5"
      >
        <div class="flex flex-wrap items-center justify-between gap-4">
          <div>
            <p class="text-xs font-semibold uppercase tracking-[0.2em] text-base-content/60">
              Sources
            </p>
            <h2 class="mt-1 text-lg font-semibold text-base-content">
              Connected feeds
            </h2>
          </div>

          <.button navigate={~p"/admin/series/#{@series}/sources/new"}>
            <.icon name="hero-plus" /> New source
          </.button>
        </div>

        <%= if @series_sources_empty? do %>
          <div
            id="series-sources-empty"
            class="mt-6 rounded-box border border-dashed border-base-300 bg-base-200/40 px-5 py-8 text-center"
          >
            <p class="font-medium text-base-content">No sources have been configured yet.</p>
            <p class="mt-2 text-sm text-base-content/70">
              Add a source to start capturing calendars, results, or standings for this series.
            </p>
            <div class="mt-5">
              <.button variant="primary" navigate={~p"/admin/series/#{@series}/sources/new"}>
                <.icon name="hero-plus" /> Add source
              </.button>
            </div>
          </div>
        <% else %>
          <div class="mt-5 overflow-x-auto">
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
              <:col :let={{_id, source}} label="Priority">{source.priority}</:col>
              <:col :let={{_id, source}} label="Active">
                <span class={["badge", (source.is_active && "badge-success") || "badge-ghost"]}>
                  {(source.is_active && "Active") || "Inactive"}
                </span>
              </:col>
              <:action :let={{_id, source}}>
                <div class="sr-only">
                  <.link navigate={~p"/admin/series/#{@series}/sources/#{source}"}>Show</.link>
                </div>
                <.link navigate={~p"/admin/series/#{@series}/sources/#{source}/edit"}>Edit</.link>
              </:action>
            </.table>
          </div>
        <% end %>
      </section>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    series = Motorsport.get_series!(id)
    series_sources = Motorsport.list_series_sources(series)
    series_seasons = Motorsport.list_seasons(series)

    {:ok,
     socket
     |> assign(:page_title, "Show Series")
     |> assign(:series, series)
     |> assign(:series_source_count, length(series_sources))
     |> assign(:series_season_count, length(series_seasons))
     |> assign(:series_sources_empty?, series_sources == [])
     |> assign(:series_seasons_empty?, series_seasons == [])
     |> stream(:series_sources, series_sources)
     |> stream(:series_seasons, series_seasons)}
  end

  defp series_description(nil), do: "No description has been added yet."
  defp series_description(""), do: "No description has been added yet."
  defp series_description(description), do: description

  defp metadata_text(nil), do: "{}"
  defp metadata_text(metadata), do: inspect(metadata)

  defp format_date(nil), do: "Not set"
  defp format_date(date), do: Calendar.strftime(date, "%Y-%m-%d")
end
