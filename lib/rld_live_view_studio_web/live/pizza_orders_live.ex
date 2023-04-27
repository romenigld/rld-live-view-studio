defmodule RldLiveViewStudioWeb.PizzaOrdersLive do
  use RldLiveViewStudioWeb, :live_view
  alias RldLiveViewStudio.PizzaOrders

  import Number.Currency

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(params, _uri, socket) do
    sort_order = valid_sort_order(params)
    sort_by = valid_sort_by(params)
    page = param_to_integer(params["page"], 1)
    per_page = param_to_integer(params["per_page"], 5)

    options = %{
      sort_by: sort_by,
      sort_order: sort_order,
      page: page,
      per_page: per_page
    }

    socket =
      assign(socket,
        pizza_orders: PizzaOrders.list_pizza_orders(options),
        options: options,
        pizza_orders_count: PizzaOrders.pizza_orders_count()
      )

    {:noreply, socket}
  end

  attr(:sort_by, :atom, required: true)
  attr(:options, :map, required: true)
  slot(:inner_block, required: true)

  def sort_link(assigns) do
    ~H"""
    <.link patch={
      ~p"/pizza-orders?#{%{@options | sort_by: @sort_by, sort_order: next_sort_order(@options.sort_order)}}"
    }>
      <%= render_slot(@inner_block) %>
      <%= sort_indicator(@sort_by, @options, assigns) %>
    </.link>
    """
  end

  def handle_event("select-per-page", %{"per-page" => per_page}, socket) do
    params = %{socket.assigns.options | per_page: per_page}

    socket = push_patch(socket, to: ~p"/pizza-orders?#{params}")
    {:noreply, socket}
  end

  # defp next_sort_order(options) do
  #   case options.sort_order do
  #     :asc -> :desc
  #     :desc -> :asc
  #   end
  # end

  defp next_sort_order(:asc), do: :desc
  defp next_sort_order(:desc), do: :asc

  defp valid_sort_order(%{"sort_order" => sort_order})
       when sort_order in ~w(asc desc) do
    String.to_existing_atom(sort_order)
  end

  defp valid_sort_order(_params), do: :asc

  defp valid_sort_by(%{"sort_by" => sort_by})
       when sort_by in ~w(id size style topping_1 topping_2 price) do
    String.to_existing_atom(sort_by)
  end

  defp valid_sort_by(_params), do: :id

  defp param_to_integer(nil, default), do: default

  defp param_to_integer(params, default) do
    case Integer.parse(params) do
      {number, _} -> number
      :error -> default
    end
  end

  # defp sort_indicator(column, %{sort_by: sort_by, sort_order: sort_order})
  #      when column == sort_by do
  #   case sort_order do
  #     :asc -> "👆"
  #     :desc -> "👇"
  #   end
  # end

  # defp sort_indicator(_, _), do: ""

  defp sort_indicator(column, %{sort_by: sort_by, sort_order: sort_order}, assigns)
       when column == sort_by do
    case sort_order do
      :asc -> chevron_up(assigns)
      :desc -> chevron_down(assigns)
    end
  end

  defp sort_indicator(_, _, _), do: ""

  defp chevron_up(assigns) do
    ~H"""
    <Heroicons.chevron_up class="w-4 h-4" />
    """
  end

  defp chevron_down(assigns) do
    ~H"""
    <Heroicons.chevron_down class="w-4 h-4" />
    """
  end

  defp more_pages?(options, pizza_orders_count) do
    options.page * options.per_page < pizza_orders_count
  end

  defp pages(options, pizza_orders_count) do
    page_count = ceil(pizza_orders_count / options.per_page)

    for page_number <- (options.page - 2)..(options.page + 2),
        page_number > 0 do
      if page_number <= page_count do
        current_page? = page_number == options.page
        {page_number, current_page?}
      end
    end
  end
end
