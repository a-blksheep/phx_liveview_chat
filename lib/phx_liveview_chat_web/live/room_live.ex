defmodule ChatWeb.RoomLive do
  @moduledoc false

  use ChatWeb, :live_view
  require Logger

  @impl true
  def mount(%{"id" => room_id}, _session, socket) do
    topic = "room:" <> room_id
    username = MnemonicSlugs.generate_slug(2)

    if connected?(socket) do
      ChatWeb.Endpoint.subscribe(topic)
      ChatWeb.Presence.track(self(), topic, username, %{})
    end

    socket =
      socket
      |> assign(:room_id, room_id)
      |> assign(:topic, topic)
      |> assign(:username, username)
      |> assign(:message, "")
      |> assign(:messages, [])
      |> assign(:user_list, [])
      |> assign(:temporary_assigns, messages: [])

    {:ok, socket}
  end

  @impl true
  def handle_event("submit_message", %{"chat" => %{"message" => message}}, socket) do
    Logger.info(message: message)

    message = generate_message_map(message, socket.assigns.username)

    ChatWeb.Endpoint.broadcast(socket.assigns.topic, "new-message", message)

    socket =
      socket
      |> assign(:message, "")

    {:noreply, socket}
  end

  @impl true
  def handle_event("form_updated", %{"chat" => %{"message" => message}}, socket) do
    Logger.info(message: message)

    socket =
      socket
      |> assign(:message, message)

    {:noreply, socket}
  end

  @impl true
  def handle_info(%{event: "new-message", payload: message}, socket) do
    Logger.info(payload: message)

    socket =
      socket
      |> assign(:messages, [message])

    {:noreply, socket}
  end

  @impl true
  def handle_info(%{event: "presence_diff", payload: %{joins: joins, leaves: leaves}}, socket) do
    Logger.info(joins: joins, leaves: leaves)

    join_messages =
      joins
      |> Map.keys()
      |> Enum.map(fn username ->
        %{type: :system, uuid: UUID.uuid4(), content: "#{username} joined the chat"}
      end)

    leave_messages =
      leaves
      |> Map.keys()
      |> Enum.map(fn username ->
        %{type: :system, uuid: UUID.uuid4(), content: "#{username} left the chat"}
      end)

    user_list =
      ChatWeb.Presence.list(socket.assigns.topic)
      |> Map.keys()

    socket =
      socket
      |> assign(:messages, join_messages ++ leave_messages)
      |> assign(:user_list, user_list)

    {:noreply, socket}
  end

  defp generate_message_map(content, username),
    do: %{uuid: UUID.uuid4(), content: content, username: username}

  defp display_message(%{type: :system, uuid: _uuid, content: _content} = assigns) do
    ~H"""
    <p id={@uuid}>
        <em><%= @content %></em>
    </p>
    """
  end

  defp display_message(%{uuid: _uuid, content: _content, username: _username} = assigns) do
    ~H"""
    <p id={@uuid}>
    <strong><%= @username%></strong>:
    <%= @content %>
    </p>
    """
  end
end
