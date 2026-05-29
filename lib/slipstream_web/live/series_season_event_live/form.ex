defmodule SlipstreamWeb.SeriesSeasonEventLive.Form do
  use SlipstreamWeb, :live_view

  alias Slipstream.Motorsport
  alias Slipstream.Motorsport.Event

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
        <:subtitle>Correct event details when the calendar changes.</:subtitle>
      </.header>

      <.form for={@form} id="season-event-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:round]} type="number" label="Round" min="1" />
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:venue_name]} type="text" label="Venue" />
        <.input field={@form[:location]} type="text" label="Location" />
        <.input field={@form[:country]} type="text" label="Country" />
        <.input field={@form[:starts_on]} type="date" label="Starts on" />
        <.input field={@form[:ends_on]} type="date" label="Ends on" />
        <.input field={@form[:timezone]} type="text" label="Timezone" />
        <.input field={@form[:status]} type="select" label="Status" options={status_options()} />
        <.input field={@form[:sessions_json]} type="textarea" label="Sessions JSON" rows="8" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Event</.button>
          <.button navigate={return_path(@return_to, @series, @season, @event)}>Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    series = Motorsport.get_series!(params["series_id"])
    season = Motorsport.get_season!(series, params["season_id"])

    {:ok,
     socket
     |> assign(:series, series)
     |> assign(:season, season)
     |> assign(:return_to, return_to(params["return_to"]))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    event = Motorsport.get_event!(socket.assigns.season, id)

    socket
    |> assign(:page_title, "Edit Event")
    |> assign(:event, event)
    |> assign(:form, to_form(Motorsport.change_event(event)))
  end

  defp apply_action(socket, :new, _params) do
    event = %Event{season_id: socket.assigns.season.id}

    socket
    |> assign(:page_title, "New Event")
    |> assign(:event, event)
    |> assign(:form, to_form(Motorsport.change_event(event)))
  end

  @impl true
  def handle_event("validate", %{"event" => event_params}, socket) do
    changeset = Motorsport.change_event(socket.assigns.event, event_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"event" => event_params}, socket) do
    save_event(socket, socket.assigns.live_action, event_params)
  end

  defp save_event(socket, :edit, event_params) do
    case Motorsport.update_event(socket.assigns.event, event_params) do
      {:ok, event} ->
        {:noreply,
         socket
         |> put_flash(:info, "Event updated successfully")
         |> push_navigate(
           to:
             return_path(
               socket.assigns.return_to,
               socket.assigns.series,
               socket.assigns.season,
               event
             )
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_event(socket, :new, event_params) do
    case Motorsport.create_event(socket.assigns.season, event_params) do
      {:ok, event} ->
        {:noreply,
         socket
         |> put_flash(:info, "Event created successfully")
         |> push_navigate(
           to:
             return_path(
               socket.assigns.return_to,
               socket.assigns.series,
               socket.assigns.season,
               event
             )
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path("index", series, season, _event),
    do: ~p"/admin/series/#{series}/seasons/#{season}/events"

  defp return_path("show", series, season, event),
    do: ~p"/admin/series/#{series}/seasons/#{season}/events/#{event}"

  defp status_options do
    [
      {"Scheduled", "scheduled"},
      {"Postponed", "postponed"},
      {"Cancelled", "cancelled"},
      {"Rescheduled", "rescheduled"}
    ]
  end
end
