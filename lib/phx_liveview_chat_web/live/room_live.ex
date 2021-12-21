defmodule ChatWeb.RoomLive do
  @moduledoc false

  use ChatWeb, :live_view
  require Logger

  @impl true
  def mount(%{"id" => room_id}, _session, socket) do
    topic = "room:" <> room_id
    if connected?(socket), do: ChatWeb.Endpoint.subscribe(topic)

    socket =
      socket
      |> assign(:room_id, room_id)
      |> assign(:topic, topic)
      |> assign(:message, "")
      |> assign(:messages, [generate_message_map("Blksheep joined the chat")])
      |> assign(:temporary_assigns, messages: [])

    {:ok, socket}
  end

  @impl true
  def handle_event("submit_message", %{"chat" => %{"message" => message}}, socket) do
    Logger.info(message: message)
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
      |> assign(:messages, [generate_message_map(message)])

    {:noreply, socket}
  end

  defp generate_message_map(content), do: %{uuid: UUID.uuid4(), content: content}
end
