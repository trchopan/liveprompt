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
    sample_content = """
    <h1>This is example title</h1>

    <p>You can edit this content in the <span class="text-warning font-bold">Control</span> panel</p>
    """

    ~H"""
    <div phx-hook="LightOut" id="view-live-container" class="flex flex-col h-screen">
      <div class="pb-3 flex place-content-between">
        <.back navigate={~p"/"}>Back</.back>
        <p class="text-sm">
          Go to <.link href={~p"/control"} class="text-warning font-bold">Control</.link>
        </p>
      </div>
      <div id="view-content" phx-hook="ViewContent" class="prose h-full overflow-y-scroll text-white">
        <%= if String.trim(@content) == "", do: raw(sample_content), else: raw(@content) %>
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    socket = socket |> assign(page_title: "View")

    if connected?(socket) do
      Phoenix.PubSub.subscribe(Liveprompt.PubSub, "control")

      socket =
        socket
        |> assign(:loading, false)
        |> assign(:content, "")
        |> assign(:range, 0)

      {:ok, socket}
    else
      {:ok, assign(socket, loading: true)}
    end
  end

  @impl true
  def handle_info({:content, content}, socket) do
    with {:ok, html_doc, _message} <- Earmark.as_html(content) do
      {:noreply, assign(socket, content: html_doc)}
    else
      {:error, html_doc, message} ->
        IO.inspect(html_doc, label: "error")
        IO.inspect(message, label: "error")
        {:noreply, socket}
    end
  end

  @impl true
  def handle_info({:range, range}, socket) do
    socket =
      socket
      |> push_event("view-content:range", %{range: range})
      |> assign(range: range)

    {:noreply, socket}
  end

  @impl true
  def handle_info(payload, socket) do
    IO.inspect(payload, label: "payload")
    {:noreply, socket}
  end
end
