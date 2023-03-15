defmodule RldLiveViewStudioWeb.LightLive do
  use RldLiveViewStudioWeb, :live_view

  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        brightness: 10
      )

    # Alternatively, if you know that you'll only need to assign one key/value pair, then you can call the assign/3 function
    # assign(socket, :brightness, 10)
    # IO.inspect(socket, label: "mount")
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>Front Porch Light</h1>
    <div id="light">
      <div class="meter">
        <span style={"width: #{@brightness}%"}>
          <%= @brightness %>%
        </span>
      </div>
      <button phx-click="off">
        <img src="/images/light-off.svg" />
      </button>
      <button phx-click="down">
        <img src="/images/down.svg" />
      </button>
      <button phx-click="random">
        <img src="/images/fire.svg" />
      </button>
      <button phx-click="up">
        <img src="/images/up.svg" />
      </button>
      <button phx-click="on">
        <img src="/images/light-on.svg" />
      </button>
    </div>
    """
  end

  def handle_event("on", _params, socket) do
    socket = assign(socket, brightness: 100)
    {:noreply, socket}
  end

  def handle_event("off", _params, socket) do
    socket = assign(socket, brightness: 0)
    ## IO.inspect(socket, label: "off")
    {:noreply, socket}
  end

  def handle_event("down", _params, socket) do
    socket =
      update(
        socket,
        :brightness,
        &max(&1 - 10, 0)
      )

    {:noreply, socket}
  end

  def handle_event("up", _params, socket) do
    socket = update(socket, :brightness, &min(&1 + 10, 100))
    {:noreply, socket}
  end

  def handle_event("random", _params, socket) do
    socket =
      assign(socket,
        brightness: Enum.random(0..100)
      )

    # IO.inspect(socket, label: "random")
    {:noreply, socket}
  end
end
