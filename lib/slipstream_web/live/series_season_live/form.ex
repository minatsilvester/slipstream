defmodule SlipstreamWeb.SeriesSeasonLive.Form do
  use SlipstreamWeb, :live_view

  alias Slipstream.Motorsport
  alias Slipstream.Motorsport.Season

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
        <:subtitle>Keep the calendar year aligned with the official Formula 1 season.</:subtitle>
      </.header>

      <.form for={@form} id="series-season-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:year]} type="number" label="Year" min="1900" />
        <.input field={@form[:starts_on]} type="date" label="Starts on" />
        <.input field={@form[:ends_on]} type="date" label="Ends on" />
        <.input field={@form[:is_current]} type="checkbox" label="Current season" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Season</.button>
          <.button navigate={return_path(@return_to, @series, @season)}>Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    series = Motorsport.get_series!(params["series_id"])

    {:ok,
     socket
     |> assign(:series, series)
     |> assign(:return_to, return_to(params["return_to"]))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    season = Motorsport.get_season!(socket.assigns.series, id)

    socket
    |> assign(:page_title, "Edit Season")
    |> assign(:season, season)
    |> assign(:form, to_form(Motorsport.change_season(season)))
  end

  defp apply_action(socket, :new, _params) do
    season = %Season{series_id: socket.assigns.series.id}

    socket
    |> assign(:page_title, "New Season")
    |> assign(:season, season)
    |> assign(:form, to_form(Motorsport.change_season(season)))
  end

  @impl true
  def handle_event("validate", %{"season" => season_params}, socket) do
    changeset = Motorsport.change_season(socket.assigns.season, season_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"season" => season_params}, socket) do
    save_season(socket, socket.assigns.live_action, season_params)
  end

  defp save_season(socket, :edit, season_params) do
    case Motorsport.update_season(socket.assigns.season, season_params) do
      {:ok, season} ->
        {:noreply,
         socket
         |> put_flash(:info, "Season updated successfully")
         |> push_navigate(
           to: return_path(socket.assigns.return_to, socket.assigns.series, season)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_season(socket, :new, season_params) do
    case Motorsport.create_season(socket.assigns.series, season_params) do
      {:ok, season} ->
        {:noreply,
         socket
         |> put_flash(:info, "Season created successfully")
         |> push_navigate(
           to: return_path(socket.assigns.return_to, socket.assigns.series, season)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path("index", series, _season), do: ~p"/admin/series/#{series}/seasons"
  defp return_path("show", series, season), do: ~p"/admin/series/#{series}/seasons/#{season}"
end
