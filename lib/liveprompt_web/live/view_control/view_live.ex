defmodule LivepromptWeb.ViewLive do
  alias Liveprompt.ViewControls.Content
  alias LivepromptWeb.ViewControl.Components
  use LivepromptWeb, :live_view

  @impl true
  def render(%{loading: true} = assigns) do
    ~H"""
    Liveprompt is loading...
    """
  end

  @impl true
  def render(%{loading: false} = assigns) do
    ~H"""
    <div phx-hook="LightOut" id="view-live-container" class="flex flex-col h-screen">
      <Components.top_view_control
        current_user={@current_user}
        content_id={@content.id}
        is_control={false}
      />
      <div
        id="view-content"
        phx-hook="ViewContent"
        class="prose w-full h-full overflow-y-scroll text-white mx-auto py-8"
      >
      </div>
    </div>
    """
  end

  @impl true
  def mount(%{"content_id" => content_id}, _session, socket) do
    socket = socket |> assign(page_title: "View")

    if connected?(socket) do
      Phoenix.PubSub.subscribe(Liveprompt.PubSub, "control" <> content_id)

      maybe_socket =
        {:ok, socket}
        |> Components.check_invalid_content_id(content_id)
        |> Components.check_content_is_found(content_id)
        |> Components.check_content_is_private(
          socket.assigns.current_user,
          fallback_content(content_id)
        )

      case maybe_socket do
        {:error, socket} ->
          {:ok, socket}

        {:ok, socket} ->
          {:ok, mount_with_content(socket)}
      end
    else
      {:ok, assign(socket, loading: true)}
    end
  end

  def mount(_params, _session, socket) do
    content_id = Ecto.UUID.generate()
    {view_link, _} = Components.make_view_control_links(content_id)
    IO.inspect(view_link, label: ">>> view_link")
    {:ok, redirect(socket, to: view_link)}
  end

  defp mount_with_content(socket) do
    content = socket.assigns.content

    socket
    |> assign(:loading, false)
    |> assign(:flip, false)
    |> assign(:range, 0.0)
    |> push_event("view_content", %{content: content.content})
  end

  # Handle PubSub events

  @impl true
  def handle_info({:content, content}, socket) do
    socket =
      socket
      |> push_event("view_content", %{content: content.content})
      |> assign(content: content)

    {:noreply, socket}
  end

  @impl true
  def handle_info({:scroll, scroll}, socket) do
    socket =
      socket
      |> push_event("view_scroll", %{scroll: scroll})
      |> assign(scroll: scroll)

    {:noreply, socket}
  end

  @impl true
  def handle_info({:flip, flip}, socket) do
    socket =
      socket
      |> push_event("view_flip", %{flip: flip})
      |> assign(flip: flip)

    {:noreply, socket}
  end

  defp fallback_content(content_id) do
    %Content{
      id: content_id,
      name: "Public",
      content: Components.view_instruction()
    }
  end
end
