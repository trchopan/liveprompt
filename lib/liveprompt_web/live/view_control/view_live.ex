defmodule LivepromptWeb.ViewLive do
  use LivepromptWeb, :live_view

  @impl true
  def render(%{loading: true} = assigns) do
    ~H"""
    Liveprompt is loading...
    """
  end

  @impl true
  def render(%{loading: false} = assigns) do
    youtube_introduction_video = Application.get_env(:liveprompt, :youtube_introduction_video)

    sample_content = """
    <h1>See the introduction video</h1>
    <p>
      <a href="#{youtube_introduction_video}">Liveprompt Introduction</a>
    </p>
    <h1>How to use the app</h1>
    <p>You can edit this content in the <span class="text-warning font-bold">Control</span> panel.</p>
    <p>This application is intended to be used with <u>two devices</u>. One device serves as the Control, while the other functions as the View.</p>
    <p>Changes made to the content of the Control will be immediately reflected in the View.</p>
    <p>The Control and View listen to each other via the unique <span class="text-pink-400 font-bold">ID</span>.</p>
    """

    ~H"""
    <div phx-hook="LightOut" id="view-live-container" class="flex flex-col h-screen">
      <.live_component
        module={LivepromptWeb.ViewControl.ViewControlTopLive}
        id="view-control-top"
        uuid={@uuid}
        is_control={true}
      />
      <div
        id="view-content"
        phx-hook="ViewContent"
        class="prose w-full h-full overflow-y-scroll text-white mx-auto"
      >
        <%= if String.trim(@content) == "", do: raw(sample_content), else: raw(@content) %>
      </div>
    </div>
    """
  end

  @impl true
  def mount(%{"uuid" => uuid}, _session, socket) do
    socket = socket |> assign(page_title: "View")

    if connected?(socket) do
      Phoenix.PubSub.subscribe(Liveprompt.PubSub, "control" <> uuid)

      socket =
        socket
        |> assign(:loading, false)
        |> assign(:uuid, uuid)
        |> assign(:flip, false)
        |> assign(:content, "")
        |> assign(:range, 0)

      {:ok, socket}
    else
      {:ok, assign(socket, loading: true)}
    end
  end

  def mount(_params, _session, socket) do
    uuid = Ecto.UUID.generate()
    {:ok, redirect(socket, to: ~p"/view/#{uuid}")}
  end

  @impl true
  def handle_info({:content, content}, socket) do
    with {:ok, html_doc, _message} <- Earmark.as_html(content) do
      {:noreply, assign(socket, content: html_doc)}
    else
      {:error, html_doc, message} ->
        IO.inspect(html_doc, label: "html_doc")
        IO.inspect(message, label: "message")
        {:noreply, socket}
    end
  end

  @impl true
  def handle_info({:range, range}, socket) do
    socket =
      socket
      |> push_event("view:range", %{range: range})
      |> assign(range: range)

    {:noreply, socket}
  end

  @impl true
  def handle_info({:flip, flip}, socket) do
    socket =
      socket
      |> push_event("view:flip", %{flip: flip})
      |> assign(flip: flip)

    {:noreply, socket}
  end

  @impl true
  def handle_info(payload, socket) do
    IO.inspect(payload, label: "payload")
    {:noreply, socket}
  end
end
