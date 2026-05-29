defmodule Slipstream.Ingestion.Formula1CalendarSync do
  use GenServer

  require Logger

  alias Slipstream.Ingestion.Formula1CalendarParser
  alias Slipstream.Motorsport

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  def topic(season_id), do: "ingestion:formula1_calendar:season:#{season_id}"

  def start_sync(season) do
    child_spec = %{
      id: {__MODULE__, season.id},
      start: {__MODULE__, :start_link, [[season_id: season.id, year: season.year]]},
      restart: :temporary
    }

    DynamicSupervisor.start_child(Slipstream.Ingestion.Supervisor, child_spec)
  end

  @impl true
  def init(opts) do
    season_id = Keyword.fetch!(opts, :season_id)
    year = Keyword.fetch!(opts, :year)
    season = Slipstream.Repo.get!(Slipstream.Motorsport.Season, season_id)
    source = Motorsport.get_series_calendar_source!(season)

    state = %{
      season_id: season_id,
      year: year,
      source: source,
      status: :processing,
      started_at: DateTime.utc_now(),
      entries: [],
      error: nil
    }

    send(self(), :run)
    broadcast(state.season_id, %{status: :processing, message: "Calendar sync started"})
    {:ok, state}
  end

  @impl true
  def handle_info(:run, state) do
    finish_state = run_sync(state)

    broadcast(finish_state.season_id, %{
      status: finish_state.status,
      entries: finish_state.entries,
      error: finish_state.error
    })

    {:stop, :normal, finish_state}
  end

  defp run_sync(state) do
    url = build_calendar_url(state.source.url, state.year)
    extraction_config = build_extraction_config(state.source.extraction_config, state.year)

    Logger.info("Formula 1 calendar sync start season=#{state.season_id} url=#{url}")

    with {:ok, %{body: body}} <- fetch_calendar(url),
         entries when is_list(entries) <- Formula1CalendarParser.parse(body, extraction_config) do
      Logger.info(
        "Formula 1 calendar sync parsed season=#{state.season_id} entries=#{inspect(entries)}"
      )

      %{state | entries: entries, status: :done, error: nil}
    else
      {:error, error} ->
        Logger.error(
          "Formula 1 calendar sync failed season=#{state.season_id} error=#{inspect(error)}"
        )

        %{state | status: :failed, error: inspect(error)}

      other ->
        Logger.error(
          "Formula 1 calendar sync failed season=#{state.season_id} error=#{inspect(other)}"
        )

        %{state | status: :failed, error: inspect(other)}
    end
  end

  defp fetch_calendar(url) do
    Req.get(url: url)
  end

  defp build_calendar_url(base_url, year) do
    base = String.trim_trailing(base_url, "/")

    if String.ends_with?(base, "/#{year}") do
      base
    else
      "#{base}/#{year}"
    end
  end

  defp build_extraction_config(nil, year), do: Formula1CalendarParser.extraction_config(year)

  defp build_extraction_config(config, year) when is_map(config) do
    config
    |> Map.put_new("card_selector", ~s(a[href^="/en/racing/#{year}/"]))
    |> Map.put_new("detail_link_selector", ~s(a[href^="/en/racing/#{year}/"]))
  end

  defp broadcast(season_id, payload) do
    Phoenix.PubSub.broadcast(
      Slipstream.PubSub,
      topic(season_id),
      {:formula1_calendar_sync, Map.merge(%{season_id: season_id}, payload)}
    )
  end
end
