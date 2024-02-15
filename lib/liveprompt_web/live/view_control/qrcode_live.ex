defmodule LivepromptWeb.ViewControl.QrcodeLive do
  use LivepromptWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
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
    """
  end
end
