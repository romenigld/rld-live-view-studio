defmodule RldLiveViewStudioWeb.TopSecretLive do
  use RldLiveViewStudioWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <%= live_render(@socket, RldLiveViewStudioWeb.LightLive, id: "light") %>

    <div id="top-secret">
      <img src="/images/spy.svg" />
      <div class="mission">
        <h1>Top Secret</h1>
        <h2>Your Mission</h2>
        <h3><%= pad_user_id(@current_user.id) %></h3>
        <p>
          Storm the castle and capture 3 bottles of Elixir.
        </p>
      </div>
    </div>
    """
  end

  def pad_user_id(user) do
    user
    |> Integer.to_string()
    |> String.pad_leading(3, "0")
  end
end
