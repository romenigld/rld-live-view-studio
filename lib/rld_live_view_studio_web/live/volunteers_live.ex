defmodule RldLiveViewStudioWeb.VolunteersLive do
  use RldLiveViewStudioWeb, :live_view
  alias RldLiveViewStudio.Volunteers
  alias RldLiveViewStudio.Volunteers.Volunteer

  def mount(_params, _session, socket) do
    volunteers = Volunteers.list_volunteers()

    changeset = Volunteers.change_volunteer(%Volunteer{})

    socket =
      socket
      |> stream(:volunteers, volunteers)
      |> assign(:form, to_form(changeset))

    IO.inspect(socket.assigns.streams.volunteers, label: "mount")

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>Volunteer Check-In</h1>
    <div id="volunteer-checkin">
      <.volunteer_form form={@form} />

      <pre>
        <%#= inspect(@form, pretty: true) %>
      </pre>
      <div id="volunteers" phx-update="stream">
        <.volunteer
          :for={{volunteer_id, volunteer} <- @streams.volunteers}
          volunteer={volunteer}
          id={volunteer_id}
        />
      </div>
    </div>
    """
  end

  def volunteer_form(assigns) do
    ~H"""
    <.form for={@form} phx-submit="save" phx-change="validate">
      <.input field={@form[:name]} placeholder="Name" autocomplete="off" phx-debounce="2000" />
      <.input
        field={@form[:phone]}
        type="tel"
        placeholder="Phone"
        autocomplete="off"
        phx-debounce="blur"
      />
      <.button phx-disable-with="Saving...">
        Check In
      </.button>
    </.form>
    """
  end

  def volunteer(assigns) do
    ~H"""
    <div class={"volunteer #{if @volunteer.checked_out, do: "out"}"} id={@id}>
      <div class="name">
        <%= @volunteer.name %>
      </div>
      <div class="phone">
        <%= @volunteer.phone %>
      </div>
      <div class="status">
        <button phx-click="toggle-status" phx-value-id={@volunteer.id}>
          <%= if @volunteer.checked_out,
            do: "Check In",
            else: "Check Out" %>
        </button>
      </div>
      <.link
        class="delete"
        phx-click="delete"
        phx-value-id={@volunteer.id}
        data-confirm="Are you sure?"
      >
        <.icon name="hero-trash-solid" />
      </.link>
    </div>
    """
  end

  def handle_event("delete", %{"id" => id}, socket) do
    volunteer = Volunteers.get_volunteer!(id)
    {:ok, _} = Volunteers.delete_volunteer(volunteer)

    socket = stream_delete(socket, :volunteers, volunteer)

    IO.inspect(socket.assigns.streams.volunteers, label: "delete")

    {:noreply, socket}
  end

  def handle_event("toggle-status", %{"id" => id}, socket) do
    volunteer = Volunteers.get_volunteer!(id)

    {:ok, volunteer} = Volunteers.toggle_status_volunteer(volunteer)

    socket =
      stream_insert(
        socket,
        :volunteers,
        volunteer
      )

    {:noreply, socket}
  end

  def handle_event("save", %{"volunteer" => volunteer_params}, socket) do
    case Volunteers.create_volunteer(volunteer_params) do
      {:ok, volunteer} ->
        socket = stream_insert(socket, :volunteers, volunteer, at: 0)

        IO.inspect(socket.assigns.streams.volunteers, label: "save")

        changeset = Volunteers.change_volunteer(%Volunteer{})

        socket = put_flash(socket, :info, "Volunteer successfully checked in!")

        {:noreply, assign(socket, :form, to_form(changeset))}

      {:error, changeset} ->
        socket = put_flash(socket, :error, "Volunteer form has an error!")
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  def handle_event("validate", %{"volunteer" => volunteer_params}, socket) do
    IO.inspect(socket.assigns.streams.volunteers, label: "validate")

    changeset =
      %Volunteer{}
      |> Volunteers.change_volunteer(volunteer_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :form, to_form(changeset))}
  end
end
