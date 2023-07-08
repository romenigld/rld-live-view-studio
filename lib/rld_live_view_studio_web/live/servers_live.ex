defmodule RldLiveViewStudioWeb.ServersLive do
  use RldLiveViewStudioWeb, :live_view

  alias RldLiveViewStudio.Servers
  alias RldLiveViewStudioWeb.ServerFormComponent

  def mount(_params, _session, socket) do
    if connected?(socket), do: Servers.subscribe()

    servers = Servers.list_servers()

    socket =
      socket
      |> assign(:servers, servers)
      |> assign(:coffees, 0)

    # if use the temporary_assigns the value of @servers will be an empty list when it will be clicked to another server.
    # Therefore, the :for comprehension won't render anything.
    # {:ok, socket, temporary_assigns: [servers: []]}

    {:ok, socket}
  end

  def handle_params(%{"id" => id}, _uri, socket) do
    server = Servers.get_server!(id)

    {:noreply,
     assign(socket,
       selected_server: server,
       page_title: "What's up #{server.name}?"
     )}
  end

  def handle_params(_, _uri, socket) do
    socket =
      if socket.assigns.live_action == :new do
        assign(socket, selected_server: nil)
      else
        assign(socket, selected_server: hd(socket.assigns.servers))
      end

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>Servers</h1>
    <div id="servers">
      <div class="sidebar">
        <div class="nav">
          <.link patch={~p"/servers/new"} class="add">
            + Add New Server
          </.link>
          <.link
            :for={server <- @servers}
            patch={~p"/servers/#{server}"}
            class={if server == @selected_server, do: "selected"}
          >
            <span class={server.status}></span>
            <%= server.name %>
          </.link>
        </div>
        <div class="coffees">
          <button phx-click="drink">
            <img src="/images/coffee.svg" />
            <%= @coffees %>
          </button>
        </div>
      </div>
      <div class="main">
        <div class="wrapper">
          <%= if @live_action == :new do %>
            <.live_component module={ServerFormComponent} id="new" />
          <% else %>
            <.server server={@selected_server} />
          <% end %>
          <div class="links">
            <a
              id={"#{@selected_server.id}-clipboard"}
              data-content={url(@socket, ~p"/servers/?id=#{@selected_server}")}
              phx-hook="Clipboard"
            >
              Copy Link
            </a>
            <.link navigate={~p"/light"}>
              Adjust Lights
            </.link>
            <.link navigate={~p"/topsecret"}>
              Top Secret
            </.link>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def server(assigns) do
    ~H"""
    <div class="server">
      <div class="header">
        <h2><%= @server.name %></h2>
        <button class={@server.status} phx-click="toggle-status" phx-value-id={@server.id}>
          <%= @server.status %>
        </button>
      </div>
      <div class="body">
        <div class="row">
          <span>
            <%= @server.deploy_count %> deploys
          </span>
          <span>
            <%= @server.size %> MB
          </span>
          <span>
            <%= @server.framework %>
          </span>
        </div>
        <h3>Last Commit Message:</h3>
        <blockquote>
          <%= @server.last_commit_message %>
        </blockquote>
      </div>
    </div>
    """
  end

  def handle_event("drink", _, socket) do
    {:noreply, update(socket, :coffees, &(&1 + 1))}
  end

  def handle_event("toggle-status", %{"id" => id}, socket) do
    server = Servers.get_server!(id)

    {:ok, server_status_updated} = Servers.toggle_status_server(server)

    # So if you want to use code underneath for the selected_server
    # comment the 1st code on the handle_info({:server_updated..." for the :selected_server
    socket = assign(socket, :selected_server, server_status_updated)

    {:noreply, socket}
  end

  def handle_info({:server_created, server}, socket) do
    socket =
      update(
        socket,
        :servers,
        fn servers -> [server | servers] end
      )

    socket = put_flash(socket, :info, "A new Server #{server.name} was created!")

    {:noreply, socket}
  end

  def handle_info({:server_updated, server_status_updated}, socket) do
    # I don't use the code for selected server of the teacher because,
    # I was using the selected_server on the event "toggle-status" and worked.
    # So if you want to use code underneath for the selected_server
    # then comment the assign select server of the event "toggle-status"

    # If the updated server is the selected server,
    # assign it so the status button is re-rendered:
    # socket =
    #   if server_status_updated.id == socket.assigns.selected_server.id do
    #     assign(socket, selected_server: server_status_updated)
    #   else
    #     socket
    #   end

    # Three ways to update the server's red/green
    # status indicator in the sidebar:

    # 1. Refetch the list of servers and assign them back.
    # socket = assign(socket, :servers, Servers.list_servers())

    # 2. Or, to avoid another database hit, find the matching
    # server in the current list of servers, replace it, and
    # assign the resulting list back:
    # servers =
    #   Enum.map(socket.assigns.servers, fn s ->
    #     if s.id == server_status_updated.id, do: server_status_updated, else: s
    #   end)

    # socket = assign(socket, servers: servers)

    # 3. Here's another way to do the same thing without
    # having to assign the servers back to the socket:

    socket =
      update(socket, :servers, fn servers ->
        for s <- servers do
          if s.id == server_status_updated.id, do: server_status_updated, else: s
        end
      end)

    {:noreply, socket}
  end
end
