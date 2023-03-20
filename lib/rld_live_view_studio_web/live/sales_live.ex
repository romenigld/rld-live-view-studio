defmodule RldLiveViewStudioWeb.SalesLive do
  use RldLiveViewStudioWeb, :live_view
  alias RldLiveViewStudio.Sales

  def mount(_params, _session, socket) do
    if connected?(socket) do
      # send message
      :timer.send_interval(1000, self(), :tick)
    end

    {:ok, assign_stats(socket)}
  end

  def render(assigns) do
    ~H"""
    <h1>Snappy Sales</h1>
    <div id="sales">
      <div class="stats">
        <div class="stat">
          <span class="value">
            <%= @new_orders %>
          </span>
          <span class="label">New Orders</span>
        </div>

        <div class="stat">
          <span class="value">
            <%= @sales_amount %>
          </span>
          <span class="label">Sales Amount</span>
        </div>

        <div class="stat">
          <span class="value">
            <%= @satisfaction %>
          </span>
          <span class="label">Satisfaction</span>
        </div>
      </div>

      <button phx-click="refresh">
        <img src="/images/refresh.svg" alt="Refresh" /> Refresh
      </button>
    </div>
    """
  end

  def handle_event("refresh", _params, socket) do
    {:noreply, assign_stats(socket)}
  end

  def handle_info(:tick, socket) do
    {:noreply, assign_stats(socket)}
  end

  defp assign_stats(socket) do
    assign(socket,
      new_orders: Sales.new_orders(),
      sales_amount: Sales.sales_amount(),
      satisfaction: Sales.sales_satisfaction()
    )
  end
end
