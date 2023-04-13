defmodule RldLiveViewStudioWeb.DonationsLive do
  use RldLiveViewStudioWeb, :live_view

  alias RldLiveViewStudio.Donations

  def mount(_params, _session, socket) do
    donations = Donations.list_donations()

    socket =
      assign(socket,
        donations: donations
      )

    {:ok, socket}
  end
end
