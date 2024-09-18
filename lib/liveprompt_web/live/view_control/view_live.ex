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
        data-content={@content.content}
        class={[
          "prose max-w-none w-full h-full overflow-y-scroll text-white mx-auto py-8 px-3",
          if(@flip, do: "horizontal-flip"),
          if(@size == 0, do: ""),
          if(@size == 1, do: "prose-lg"),
          if(@size == 2, do: "prose-xl")
        ]}
      >
      </div>
    </div>
    """
  end

  @impl true
  def mount(%{"content_id" => content_id}, _session, socket) do
    socket =
      socket
      |> assign(page_title: "View")
      |> assign(content_id: content_id)

    if connected?(socket) do
      Phoenix.PubSub.subscribe(Liveprompt.PubSub, "control" <> content_id)

      with {:ok, socket} <- Components.check_invalid_content_id(socket),
           {:ok, socket} <- Components.assign_content(socket),
           {:ok, socket} <- Components.check_user_is_owner(socket) do
        {:ok, socket |> mount_ui()}
      else
        {:error, socket, :bad_content_id} ->
          {:ok, Components.handle_bad_content_id(socket)}

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
    {:ok, redirect(socket, to: view_link)}
  end

  defp mount_ui(socket) do
    content = socket.assigns.content

    socket
    |> assign(:loading, false)
    |> assign(:flip, false)
    |> assign(:size, 0)
    |> assign(:range, 0.0)
  end

  # Handle PubSub events

  @impl true
  def handle_info({:content, content}, socket) do
    {:noreply, socket |> assign(content: content)}
  end

  @impl true
  def handle_info({:scroll, scroll}, socket) do
    socket =
      socket
      |> push_event("view_scroll_percent", %{scroll: scroll})

    {:noreply, socket}
  end

  @impl true
  def handle_info({:flip, flip}, socket) do
    {:noreply, socket |> assign(flip: flip)}
  end

  @impl true
  def handle_info({:size, size}, socket) do
    {:noreply, socket |> assign(size: size)}
  end

  @impl true
  def handle_info({:play, play}, socket) do
    socket =
      socket
      |> push_event("play", play)

    {:noreply, socket}
  end
end
