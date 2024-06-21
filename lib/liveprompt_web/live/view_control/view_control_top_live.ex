defmodule LivepromptWeb.ViewControl.ViewControlTopLive do
  use LivepromptWeb, :live_component

  def render(assigns) do
    ~H"""
    <div class="pb-2 grid grid-cols-2 md:grid-cols-[auto,1fr,auto] place-content-between">
      <.back navigate={~p"/"}>Back</.back>
      <div class="order-last col-span-2 md:order-none md:col-span-1 md:grow flex items-center justify-center gap-2">
        <p><span class="text-pink-400 font-bold">ID:</span> <%= @uuid %></p>
        <div>
          <button class="btn btn-xs" onclick="qr_code_modal.showModal()">Scan QR</button>
          <dialog id="qr_code_modal" class="modal" phx-hook="QRCodeModal" data-uuid={@uuid}>
            <div class="modal-box">
              <h3 class="font-bold text-lg">Links</h3>
              <div>
                <div role="tablist" class="tabs tabs-boxed">
                  <a id="qr-code-view" role="tab" class="tab tab-active">
                    View
                  </a>
                  <a id="qr-code-control" role="tab" class="tab">
                    Control
                  </a>
                </div>
                <div class="py-4 flex flex-col justify-center items-center">
                  <canvas id="view-qr"></canvas>
                  <canvas id="control-qr" class="hidden"></canvas>
                  <p class="py-4">Scan QR for the link</p>
                </div>
              </div>
              <div class="modal-action">
                <form method="dialog">
                  <button class="btn">Close</button>
                </form>
              </div>
            </div>
          </dialog>
        </div>
      </div>
      <p class="text-right text-sm">
        Go to
        <%= if @is_control do %>
          <.link href={~p"/control/#{@uuid}"} class="text-warning font-bold">Control</.link>
        <% else %>
          <.link href={~p"/view/#{@uuid}"} class="text-primary font-bold">View</.link>
        <% end %>
      </p>
    </div>
    """
  end
end
