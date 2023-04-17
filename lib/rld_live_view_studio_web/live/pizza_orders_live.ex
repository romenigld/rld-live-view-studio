defmodule RldLiveViewStudioWeb.PizzaOrdersLive do
  use RldLiveViewStudioWeb, :live_view
  alias RldLiveViewStudio.PizzaOrders

  import Number.Currency

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(params, _uri, socket) do
    sort_order = (params["sort_order"] || "asc") |> String.to_existing_atom()
    sort_by = (params["sort_by"] || "id") |> String.to_existing_atom()

    options = %{
      sort_by: sort_by,
      sort_order: sort_order
    }

    socket =
      assign(socket,
        pizza_orders: PizzaOrders.list_pizza_orders(options),
        options: options
      )

    {:noreply, socket}
  end

  attr(:sort_by, :atom, required: true)
  attr(:options, :map, required: true)
  slot(:inner_block, required: true)

  def sort_link(assigns) do
    IO.inspect(assigns, label: "ASSIGNS")

    ~H"""
    <.link patch={
      ~p"/pizza-orders?#{%{sort_by: @sort_by, sort_order: next_sort_order(@options.sort_order)}}"
    }>
      <%= render_slot(@inner_block) %>
    </.link>
    """
  end

  # defp next_sort_order(options) do
  #   case options.sort_order do
  #     :asc -> :desc
  #     :desc -> :asc
  #   end
  # end

  defp next_sort_order(:asc), do: :desc
  defp next_sort_order(:desc), do: :asc
end
