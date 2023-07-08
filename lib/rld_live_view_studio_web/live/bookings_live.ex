defmodule RldLiveViewStudioWeb.BookingsLive do
  use RldLiveViewStudioWeb, :live_view

  alias RldLiveViewStudio.Bookings
  import Number.Currency

  # if multiple LiveViews needed to know the current user's timezone,
  # you could define an on_mount callback that's used by a live session:
  def on_mount(:assign_time_zone, _params, _session, socket) do
    %{"timezone" => tz} = get_connect_params(socket)

    {:cont, assign(socket, :time_zone, tz |> IO.inspect(label: "TIMEZONE"))}
  end

  def mount(_params, _session, socket) do
    # when a LiveView is in the connected state, you can call get_connect_params to get the params map
    # from the socket and use pattern matching to extract the value of the "timezone" parameter:
    # if connected?(socket) do
    #   %{"timezone" => tz} = get_connect_params(socket)
    #   IO.inspect(tz, label: "TIMEZONE")
    # end

    {:ok,
     assign(socket,
       bookings: Bookings.list_bookings(),
       selected_dates: nil
     )}
  end

  def render(assigns) do
    ~H"""
    <h1>Bookings</h1>
    <div id="bookings">
      <div phx-update="ignore" id="wrapper">
        <div id="booking-calendar" phx-hook="Calendar"></div>
      </div>
      <div :if={@selected_dates} class="details">
        <div>
          <span class="date">
            <%= format_date(@selected_dates.from) %>
          </span>
          -
          <span class="date">
            <%= format_date(@selected_dates.to) %>
          </span>
          <span class="nights">
            (<%= total_nights(@selected_dates) %> nights)
          </span>
        </div>
        <div class="price">
          <%= total_price(@selected_dates) %>
        </div>
        <button phx-click="book-selected-dates">
          Book Dates
        </button>
      </div>
    </div>
    """
  end

  def handle_event("dates-picked", [from, to], socket) do
    {:noreply,
     assign(socket,
       selected_dates: %{
         from: parse_date(from),
         to: parse_date(to)
       }
     )}
  end

  def handle_event("unavailable-dates", _params, socket) do
    {:reply, %{dates: socket.assigns.bookings}, socket}
  end

  def handle_event("book-selected-dates", _, socket) do
    %{selected_dates: selected_dates, bookings: bookings} = socket.assigns

    socket =
      socket
      |> assign(:bookings, [selected_dates | bookings])
      |> assign(:selected_dates, nil)
      |> push_event("add-unavailable-dates", selected_dates)

    {:noreply, socket}
  end

  def format_date(date) do
    Timex.format!(date, "%m/%d", :strftime)
  end

  def total_nights(%{from: from, to: to}) do
    Timex.diff(to, from, :days)
  end

  def total_price(selected_dates) do
    selected_dates
    |> total_nights()
    |> then(&(&1 * 100))
    |> number_to_currency(precision: 0)
  end

  def parse_date(date_string) do
    date_string
    |> Timex.parse!("{ISO:Extended}")
    # |> Timex.Timezone.convert(:local)
    |> Timex.to_date()
  end
end
