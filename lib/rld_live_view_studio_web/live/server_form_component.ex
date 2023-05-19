defmodule RldLiveViewStudioWeb.ServerFormComponent do
  use RldLiveViewStudioWeb, :live_component
  alias RldLiveViewStudio.Servers
  alias RldLiveViewStudio.Servers.Server

  def mount(socket) do
    changeset = Servers.change_server(%Server{})

    socket = assign(socket, :form, to_form(changeset))

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div>
      <.form for={@form} phx-submit="save" phx-change="validate" phx-target={@myself}>
        <div class="field">
          <.input field={@form[:name]} placeholder="Name" phx-debounce="2000" />
        </div>
        <div class="field">
          <.input field={@form[:framework]} placeholder="Framework" phx-debounce="blur" />
        </div>
        <div class="field">
          <.input field={@form[:size]} placeholder="Size (MB)" type="number" phx-debounce="1000" />
        </div>
        <.button phx-disable-with="Saving...">
          Save
        </.button>
        <.link patch={~p"/servers"} class="cancel">
          Cancel
        </.link>
      </.form>
    </div>
    """
  end

  def handle_event("save", %{"server" => server_params}, socket) do
    case Servers.create_server(server_params) do
      {:ok, server} ->
        socket = push_patch(socket, to: ~p"/servers/#{server}")

        {:noreply, socket}

      {:error, changeset} ->
        socket = assign(socket, :form, to_form(changeset))

        {:noreply, socket}
    end
  end

  def handle_event("validate", %{"server" => server_params}, socket) do
    changeset =
      %Server{}
      |> Servers.change_server(server_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :form, to_form(changeset))}
  end
end
