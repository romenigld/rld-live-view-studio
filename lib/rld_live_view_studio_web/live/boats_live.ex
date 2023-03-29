defmodule RldLiveViewStudioWeb.BoatsLive do
  use RldLiveViewStudioWeb, :live_view

  alias RldLiveViewStudio.Boats

  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        filter: %{type: "", prices: []},
        boats: Boats.list_boats()
      )

    # not using temporary_assigns:
    # the values of the 'Sporting' type filter
    # Assigned boats: 36
    # Filtered boats: 12
    # the values of the 'Sporting' ++ ["$$"] type filter
    # Assigned boats: 12
    # Filtered boats: 4
    # {:ok, socket}

    # using the temporary_assigns:
    # the values of the 'Sporting' type filter
    # Assigned boats: 0
    # Filtered boats: 12
    # the values of the 'Sporting' ++ ["$$"] type filter
    # Assigned boats: 0
    # Filtered boats: 4
    {:ok, socket, temporary_assigns: [boats: []]}
  end

  def render(assigns) do
    ~H"""
    <h1>Daily Boat Rentals</h1>

    <.promo>
      Save 25% on rentals!
    </.promo>

    <div id="boats">
      <form phx-change="filter">
        <div class="filters">
          <select name="type">
            <%= Phoenix.HTML.Form.options_for_select(
              type_options(),
              @filter.type
            ) %>
          </select>

          <div class="prices">
            <%= for price <- ["$", "$$", "$$$"] do %>
              <input
                type="checkbox"
                name="prices[]"
                value={price}
                id={price}
                checked={price in @filter.prices}
              />

              <label for={price}>
                <%= price %>
              </label>
            <% end %>

            <input type="hidden" name="prices[]" value="" />
          </div>
        </div>
      </form>

      <div class="boats">
        <div :for={boat <- @boats} class="boat">
          <img src={boat.image} />
          <div class="content">
            <div class="model">
              <%= boat.model %>
            </div>
            <div class="details">
              <span class="price">
                <%= boat.price %>
              </span>
              <span class="type">
                <%= boat.type %>
              </span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <.promo>
      Hurry, only 3 boats left!
    </.promo>
    """
  end

  def promo(assigns) do
    ~H"""
    <div class="promo">
      <div class="deal">
        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end

  def handle_event("filter", %{"type" => type, "prices" => prices}, socket) do
    filter = %{type: type, prices: prices}

    boats = Boats.list_boats(filter)

    IO.inspect(length(socket.assigns.boats), label: "Assigned boats")
    IO.inspect(length(boats), label: "Filtered boats")

    {:noreply, assign(socket, boats: boats, filter: filter)}
  end

  defp type_options do
    [
      "All Types": "",
      Fishing: "fishing",
      Sporting: "sporting",
      Sailing: "sailing"
    ]
  end
end
