defmodule LivepromptWeb.ViewLive do
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

      with {:ok, socket} <- Components.check_invalid_content_id(socket, content_id),
           {:ok, socket} <- Components.get_content_2(socket, content_id),
           content = socket.assigns.content,
           current_user = socket.assigns.current_user,
           {:ok, socket} <-
             Components.check_user_is_owner(socket, content, current_user) do
        {:ok, socket |> mount_ui()}
      else
        {:error, socket, :bad_content_id} ->
          {:ok, socket}

        {:error, socket, :not_found_content} ->
          {:ok, Components.handle_not_found_content(socket)}

        {:error, socket, :user_is_not_content_owner} ->
          {:ok, Components.handle_user_is_not_content_owner(socket)}
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

  defp mount_ui(socket) do
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
end
