defmodule RldLiveViewStudioWeb.SandboxLive do
  use RldLiveViewStudioWeb, :live_view
  import Number.Currency
  alias RldLiveViewStudio.Sandbox

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(
        length: "0",
        width: "0",
        depth: "0",
        weight: 0.0,
        price: nil
      )

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>Build a Sandbox</h1>
    <div id="sandbox">
      <form phx-change="calculate" phx-submit="get-quote">
        <div class="fields">
          <div>
            <label for="length">Length</label>
            <div class="input">
              <input type="number" name="length" value={@length} />
              <span class="unit">feet</span>
            </div>
            <label for="width">Width</label>
            <div class="input">
              <input type="number" name="width" value={@width} />
              <span class="unit">feet</span>
            </div>
            <label for="depth">Depth</label>
            <div class="input">
              <input type="number" name="depth" value={@depth} />
              <span class="unit">inches</span>
            </div>
          </div>
        </div>
        <div class="weight">
          You need <%= @weight %> pounds of sand
        </div>
        <button type="submit">
          Get a Quote
        </button>
      </form>
      <div :if={@price} class="quote">
        Get Your personal beach today for only <%= number_to_currency(@price) %>
      </div>
    </div>
    """
  end

  def handle_event("calculate", params, socket) do
    %{"length" => l, "width" => w, "depth" => d} = params
    weight = Sandbox.calculate_weight(l, w, d)

    socket =
      assign(socket,
        length: l,
        width: w,
        depth: d,
        weight: weight,
        price: nil
      )

    {:noreply, socket}
  end

  def handle_event("get-quote", _params, socket) do
    price = Sandbox.calculate_price(socket.assigns.weight)

    {:noreply, assign(socket, price: price)}
  end
end
