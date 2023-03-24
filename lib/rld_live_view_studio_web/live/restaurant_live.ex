defmodule RldLiveViewStudioWeb.RestaurantLive do
  use RldLiveViewStudioWeb, :live_view

  alias RldLiveViewStudio.Menu

  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        filter: %{type: "", tags: []},
        products: Menu.list_products()
      )

    {:ok, socket, temporary_assigns: [products: []]}
  end

  def render(assigns) do
    ~H"""
    <h1>Menu</h1>
    <div id="menu">
      <form phx-change="filter">
        <div class="filters">
          <select name="type">
            <%= Phoenix.HTML.Form.options_for_select(
              type_options(),
              @filter.type
            ) %>
          </select>

          <br />

          <div class="tags">
            <%= for tag <- ["vegetarian", "carnivore", "red wine", "white wine", "other"] do %>
              <input type="checkbox" name="tags[]" value={tag} id={tag} checked={tag in @filter.tags} />

              <label for={tag}>
                <%= tag %>
              </label>
            <% end %>

            <input type="hidden" name="tags[]" value="" />
          </div>
        </div>
      </form>

      <div class="products">
        <div :for={product <- @products} class="product">
          <div class="emoji">
            <%= product.image %>
          </div>
          <div class="content">
            <div class="name">
              <%= product.name %>
            </div>
            <div class="description">
              <i><%= product.description %></i>
            </div>
            <div class="price">
              <%= product.price %> €
            </div>
            <div class="details">
              <span class="type">
                <%= product.type %>
              </span>
              <span class="tags">
                <%= product.tags %>
              </span>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def handle_event("filter", %{"type" => type, "tags" => tags}, socket) do
    filter = %{type: type, tags: tags}

    products = Menu.list_products(filter)

    {:noreply, assign(socket, products: products, filter: filter)}
  end

  defp type_options do
    [
      "All Types": "",
      "To Snack": "To Snack",
      Grill: "Grill",
      Dessert: "Dessert",
      Drinks: "Drinks"
    ]
  end
end
