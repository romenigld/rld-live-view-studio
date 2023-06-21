defmodule RldLiveViewStudioWeb.ShopLive do
  use RldLiveViewStudioWeb, :live_view

  alias RldLiveViewStudio.Products
  alias Phoenix.LiveView.JS

  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       products: Products.list_products(),
       cart: %{},
       show_cart: false
     )}
  end

  # Using the Phoenix.LiveView.JS for show and hide the cart, don't need anymore the handle event 'toggle-show-cart'
  # def handle_event("toggle-show-cart", _, socket) do
  #   socket = update(socket, :show_cart, fn show -> !show end)
  #   {:noreply, socket}
  # end

  def handle_event("add-product", %{"product" => product}, socket) do
    cart = Map.update(socket.assigns.cart, product, 1, &(&1 + 1))
    {:noreply, assign(socket, :cart, cart)}
  end

  def toggle_cart(js \\ %JS{}) do
    js
    |> JS.toggle(
      to: "#cart",
      in: {
        "ease-in-out duration-300",
        "translate-x-full",
        "translate-x-0"
      },
      out: {
        "ease-in-out duration-300",
        "translate-x-0",
        "translate-x-full"
      },
      time: 300
    )
    |> JS.toggle(
      to: "#backdrop",
      in: "fade-in",
      out: "fade-out"
    )
  end
end