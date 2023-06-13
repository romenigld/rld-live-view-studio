defmodule RldLiveViewStudioWeb.MusicLive do
  use RldLiveViewStudioWeb, :live_view

  alias RldLiveViewStudioWeb.Presence

  @topic "users:music"

  def mount(_params, _session, socket) do
    %{current_user: current_user} = socket.assigns

    if connected?(socket) do
      Presence.subscribe(@topic)

      {:ok, _} =
        Presence.track_user(current_user, @topic, %{
          is_playing: false
        })
    end

    presences = Presence.list_users(@topic)

    socket =
      socket
      |> assign(:is_playing, false)
      |> assign(:presences, Presence.simple_presence_map(presences))

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <pre>
      <%#= inspect(@diff, pretty: true) %>
    </pre>

    <div id="presence">
      <div class="users">
        <h2>Who's Here online and listening?</h2>
        <ul>
          <li :for={{_user_id, meta} <- @presences}>
            <span class="status">
              <%= if meta.is_playing, do: "🎧", else: "🙉" %>
            </span>
            <span class="username">
              <%= meta.username %>
            </span>
          </li>
        </ul>
      </div>
      <div class="video" phx-click="toggle-playing">
        <.icon name={if(@is_playing, do: "hero-pause-circle-solid", else: "hero-play-circle-solid")} />
      </div>
    </div>
    """
  end

  def handle_event("toggle-playing", _, socket) do
    socket = update(socket, :is_playing, fn playing -> !playing end)

    %{current_user: current_user} = socket.assigns

    Presence.update_user(current_user, @topic, %{
      is_playing: socket.assigns.is_playing
    })

    {:noreply, socket}
  end

  def handle_info(%{event: "presence_diff", payload: diff}, socket) do
    socket = Presence.handle_diff(socket, diff)
    {:noreply, socket}
  end
end
