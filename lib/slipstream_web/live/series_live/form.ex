defmodule SlipstreamWeb.SeriesLive.Form do
  use SlipstreamWeb, :live_view

  alias Slipstream.Motorsport
  alias Slipstream.Motorsport.Series

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage series records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="series-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:short_name]} type="text" label="Short name" />
        <.input field={@form[:description]} type="textarea" label="Description" />
        <.input field={@form[:sport_type]} type="text" label="Sport type" />
        <.input field={@form[:governing_body]} type="text" label="Governing body" />
        <.input field={@form[:logo_url]} type="text" label="Logo url" />
        <.input field={@form[:official_website]} type="text" label="Official website" />
        <.input field={@form[:is_active]} type="checkbox" label="Is active" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Series</.button>
          <.button navigate={return_path(@return_to, @series)}>Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    series = Motorsport.get_series!(id)

    socket
    |> assign(:page_title, "Edit Series")
    |> assign(:series, series)
    |> assign(:form, to_form(Motorsport.change_series(series)))
  end

  defp apply_action(socket, :new, _params) do
    series = %Series{}

    socket
    |> assign(:page_title, "New Series")
    |> assign(:series, series)
    |> assign(:form, to_form(Motorsport.change_series(series)))
  end

  @impl true
  def handle_event("validate", %{"series" => series_params}, socket) do
    changeset = Motorsport.change_series(socket.assigns.series, series_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"series" => series_params}, socket) do
    save_series(socket, socket.assigns.live_action, series_params)
  end

  defp save_series(socket, :edit, series_params) do
    case Motorsport.update_series(socket.assigns.series, series_params) do
      {:ok, series} ->
        {:noreply,
         socket
         |> put_flash(:info, "Series updated successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, series))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_series(socket, :new, series_params) do
    case Motorsport.create_series(series_params) do
      {:ok, series} ->
        {:noreply,
         socket
         |> put_flash(:info, "Series created successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, series))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path("index", _series), do: ~p"/admin/series"
  defp return_path("show", series), do: ~p"/admin/series/#{series}"
end
