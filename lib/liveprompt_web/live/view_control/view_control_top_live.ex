defmodule LivepromptWeb.ViewControl.ViewControlTopLive do
  use LivepromptWeb, :live_component

  def render(assigns) do
    ~H"""
    <div class="pb-2 grid grid-cols-2 md:grid-cols-[auto,1fr,auto] place-content-between">
      <.back navigate={~p"/"}>Back</.back>
      <div class="order-last col-span-2 md:order-none md:col-span-1 md:grow flex items-center justify-center gap-2">
        <p><span class="text-pink-400 font-bold">ID:</span> <%= @uuid %></p>
        <.live_component
          module={LivepromptWeb.ViewControl.QrcodeLive}
          id="qr-code-modal"
          uuid={@uuid}
        />
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
