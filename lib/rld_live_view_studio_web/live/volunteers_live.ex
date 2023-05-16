defmodule RldLiveViewStudioWeb.VolunteersLive do
  use RldLiveViewStudioWeb, :live_view
  alias RldLiveViewStudio.Volunteers
  alias RldLiveViewStudioWeb.VolunteerFormComponent

  def mount(_params, _session, socket) do
    volunteers = Volunteers.list_volunteers()

    socket =
      socket
      |> stream(:volunteers, volunteers)
      |> assign(:count, length(volunteers))

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>Volunteer Check-In</h1>
    <div id="volunteer-checkin">
      <.live_component module={VolunteerFormComponent} id={:new} count={@count} />

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

  def handle_info({VolunteerFormComponent, :volunteer_created, volunteer}, socket) do
    socket = put_flash(socket, :info, "Volunteer successfully checked in!")
    socket = update(socket, :count, &(&1 + 1))
    {:noreply, stream_insert(socket, :volunteers, volunteer, at: 0)}
  end

  def handle_info({VolunteerFormComponent, :volunteer_form_error, message}, socket) do
    socket = put_flash(socket, :error, message)
    {:noreply, socket}
  end
end
