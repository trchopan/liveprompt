defmodule LivepromptWeb.ViewControl.QrcodeLive do
  alias LivepromptWeb.Endpoint
  use LivepromptWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <button class="btn btn-xs" phx-click={show_modal_daisy("qr_modal")}>Scan QR</button>
      <div id="qr_modal" class="modal">
        <div class="modal-box">
          <h3 class="font-bold text-lg">Scan QR for the link</h3>
          <div>
            <div role="tablist" class="tabs tabs-boxed">
              <a
                role="tab"
                class={["tab", if(@current_tab == "view", do: "tab-active")]}
                phx-click={
                  JS.push("switch_tab", target: @myself, value: %{tab: "view", url: @view_link})
                }
              >
                View
              </a>
              <a
                role="tab"
                class={["tab", if(@current_tab == "control", do: "tab-active")]}
                phx-click={
                  JS.push("switch_tab", target: @myself, value: %{tab: "control", url: @control_link})
                }
              >
                Control
              </a>
            </div>
            <div class="py-4 flex flex-col justify-center items-center">
              <canvas id="qr_canvas" phx-hook="QRCodeRender" data-text={@url}></canvas>
              <p class="py-4">
                <a class="text-secondary text-xs" href={@url} target="_blank"><%= @url %></a>
              </p>
            </div>
          </div>
          <div class="modal-action">
            <button class="btn" phx-click={hide_modal_daisy("qr_modal")}>Close</button>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    socket =
      socket
      |> assign(:current_tab, "view")
      |> assign(:url, "")

    {:ok, socket}
  end

  @impl true
  def update(assigns, socket) do
    socket =
      socket
      |> assign(:view_link, Endpoint.url() <> assigns.view_link)
      |> assign(:control_link, Endpoint.url() <> assigns.control_link)
      |> assign(:url, Endpoint.url() <> assigns.view_link)

    {:ok, socket}
  end

  @impl true
  def handle_event("switch_tab", %{"tab" => tab, "url" => url}, socket) do
    socket =
      socket
      |> assign(:current_tab, tab)
      |> assign(:url, url)
      |> push_event("switch_tab", %{})

    {:noreply, socket}
  end
end
