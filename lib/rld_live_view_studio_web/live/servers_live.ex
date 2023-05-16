defmodule RldLiveViewStudioWeb.ServersLive do
  use RldLiveViewStudioWeb, :live_view

  alias RldLiveViewStudio.Servers
  alias RldLiveViewStudioWeb.ServerFormComponent

  def mount(_params, _session, socket) do
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
            <.link navigate={~p"/light"}>
              Adjust Lights
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

  def handle_event("toggle-status", %{"id" => id}, socket) do
    server = Servers.get_server!(id)

    # Rather than using the function 'change_server_status/1'.
    # You could update the server's status to the opposite of its current status by doing this:
    # new_status = if server.status == "up", do: "down", else: "up"

    {:ok, server_status_updated} =
      Servers.update_server(server, %{status: change_server_status(server.status)})

    socket = assign(socket, :selected_server, server_status_updated)

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

  def handle_event("drink", _, socket) do
    {:noreply, update(socket, :coffees, &(&1 + 1))}
  end

  def handle_info({ServerFormComponent, :server_created, server}, socket) do
    socket =
      update(
        socket,
        :servers,
        fn servers -> [server | servers] end
      )

    socket = put_flash(socket, :info, "Server created successfully!")
    socket = push_patch(socket, to: ~p"/servers/#{server}")

    {:noreply, socket}
  end

  def handle_info({ServerFormComponent, :server_form_error, msg}, socket) do
    socket = put_flash(socket, :error, msg)
    {:noreply, socket}
  end

  defp change_server_status("up"), do: "down"
  defp change_server_status("down"), do: "up"
end
