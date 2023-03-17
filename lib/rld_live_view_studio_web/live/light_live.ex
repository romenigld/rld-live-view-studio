defmodule RldLiveViewStudioWeb.LightLive do
  use RldLiveViewStudioWeb, :live_view

  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        brightness: 10,
        temp: "3000"
      )

    # Alternatively, if you know that you'll only need to assign one key/value pair, then you can call the assign/3 function
    # assign(socket, :brightness, 10)
    # Inspect socket
    # IO.inspect(socket, label: "mount")
    # Inspect the pid
    # IO.inspect(self(), label: "MOUNT")
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>Front Porch Light</h1>
    <div id="light">
      <div class="meter">
        <span style={"width: #{@brightness}%; background: #{temp_color(@temp)}"}>
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

      <form phx-change="change-temp">
        <div class="temps">
          <%= for temp <- ["3000", "4000", "5000"] do %>
            <div>
              <input type="radio" id={temp} name="temp" value={temp} checked={@temp == temp} />
              <label for={temp}><%= temp %></label>
            </div>
          <% end %>
        </div>
      </form>

      <form phx-change="update">
        <input type="range" min="0" max="100" name="brightness" value={@brightness} />
      </form>
    </div>
    """
  end

  def handle_event("change-temp", %{"temp" => temp}, socket) do
    socket =
      assign(socket,
        temp: temp
      )

    {:noreply, socket}
  end

  def handle_event("on", _params, socket) do
    socket = assign(socket, brightness: 100)

    # IO.inspect(self(), label: "on")
    # raise a rocket for test the reset pid
    # raise "🚀"
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
    # IO.inspect(self(), label: "UP")
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

  def handle_event("update", %{"brightness" => brightness_params}, socket) do
    {:noreply, assign(socket, brightness: String.to_integer(brightness_params))}
  end

  defp temp_color("3000"), do: "#F1C40D"
  defp temp_color("4000"), do: "#FEFF66"
  defp temp_color("5000"), do: "#99CCFF"
end
