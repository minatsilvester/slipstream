defmodule SlipstreamWeb.SeriesSourceLive.Form do
  use SlipstreamWeb, :live_view

  alias Slipstream.Motorsport
  alias Slipstream.Motorsport.SeriesSource

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
        <:subtitle>Store the endpoint and extraction rules for {@series.name}.</:subtitle>
      </.header>

      <.form for={@form} id="series-source-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:url]} type="textarea" label="URL" />
        <.input
          field={@form[:source_type]}
          type="select"
          label="Source type"
          options={source_type_options()}
        />
        <.input field={@form[:format]} type="select" label="Format" options={format_options()} />
        <.input
          field={@form[:http_method]}
          type="select"
          label="HTTP method"
          options={http_method_options()}
        />
        <.input field={@form[:priority]} type="number" label="Priority" min="0" />
        <.input field={@form[:is_active]} type="checkbox" label="Active" />
        <.input
          field={@form[:request_headers_json]}
          type="textarea"
          label="Request headers JSON"
          rows="5"
        />
        <.input
          field={@form[:request_params_json]}
          type="textarea"
          label="Request params JSON"
          rows="5"
        />
        <.input
          field={@form[:extraction_config_json]}
          type="textarea"
          label="Extraction config JSON"
          rows="10"
        />
        <.input field={@form[:notes]} type="textarea" label="Notes" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Source</.button>
          <.button navigate={return_path(@return_to, @series, @source)}>Cancel</.button>
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
    source = Motorsport.get_series_source!(socket.assigns.series, id)

    socket
    |> assign(:page_title, "Edit Source")
    |> assign(:source, source)
    |> assign(:form, to_form(Motorsport.change_series_source(source)))
  end

  defp apply_action(socket, :new, _params) do
    source = %SeriesSource{series_id: socket.assigns.series.id}

    socket
    |> assign(:page_title, "New Source")
    |> assign(:source, source)
    |> assign(:form, to_form(Motorsport.change_series_source(source)))
  end

  @impl true
  def handle_event("validate", %{"series_source" => source_params}, socket) do
    changeset = Motorsport.change_series_source(socket.assigns.source, source_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"series_source" => source_params}, socket) do
    save_source(socket, socket.assigns.live_action, source_params)
  end

  defp save_source(socket, :edit, source_params) do
    case Motorsport.update_series_source(socket.assigns.source, source_params) do
      {:ok, source} ->
        {:noreply,
         socket
         |> put_flash(:info, "Source updated successfully")
         |> push_navigate(
           to: return_path(socket.assigns.return_to, socket.assigns.series, source)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_source(socket, :new, source_params) do
    case Motorsport.create_series_source(socket.assigns.series, source_params) do
      {:ok, source} ->
        {:noreply,
         socket
         |> put_flash(:info, "Source created successfully")
         |> push_navigate(
           to: return_path(socket.assigns.return_to, socket.assigns.series, source)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path("index", series, _source), do: ~p"/admin/series/#{series}/sources"
  defp return_path("show", series, source), do: ~p"/admin/series/#{series}/sources/#{source}"

  defp source_type_options do
    Enum.map(SeriesSource.source_types(), &{String.capitalize(&1), &1})
  end

  defp format_options do
    Enum.map(SeriesSource.formats(), &{String.upcase(&1), &1})
  end

  defp http_method_options do
    Enum.map(SeriesSource.http_methods(), &{&1, &1})
  end
end
