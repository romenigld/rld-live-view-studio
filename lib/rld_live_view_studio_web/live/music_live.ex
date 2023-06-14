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
        <%!--
          For work the buttons(Play, Pause, Vol +, Vol -)
          hide the built-in browser UI (by removing the controls attribute from audio)
          and instead build your own interface and control the playback using Javascript
        --%>
        <audio
          id="player"
          src="https://s3-us-west-2.amazonaws.com/s.cdpn.io/9473/new_year_dubstep_minimix.ogg"
        >
        </audio>
        <div>
          <button onclick="document.getElementById('player').play()">Play</button>
          <button onclick="document.getElementById('player').pause()">Pause</button>
        </div>

        <%= if @is_playing do %>
          <button onclick="document.getElementById('player').pause()">
            <.icon name="hero-pause-circle-solid" />
          </button>
        <% else %>
          <button onclick="document.getElementById('player').play()">
            <.icon name="hero-play-circle-solid" />
          </button>
        <% end %>

        <%!--
          This audio don't worked with the Presence because don't
          hide the built-in browser UI (it has the controls attribute
          from audio like: controls, loop and autoplay)
        --%>
        <div class="container-audio">
          <figure>
            <figcaption>Music Techno</figcaption>
            <audio controls loop autoplay>
              <source
                src="https://s3-us-west-2.amazonaws.com/s.cdpn.io/9473/new_year_dubstep_minimix.ogg"
                type="audio/ogg"
              /> Your browser dose not Support the audio Tag
            </audio>
          </figure>
        </div>
      </div>
      <div class="volume">
        <button
          class="bg-orange-400 rounded-full"
          onclick="document.getElementById('player').volume += 0.1"
        >
          Vol +
        </button>
        <button
          class="rounded-full bg-lime-200"
          onclick="document.getElementById('player').volume -= 0.1"
        >
          Vol -
        </button>
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
