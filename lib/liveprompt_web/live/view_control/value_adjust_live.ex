defmodule LivepromptWeb.ViewControl.ValueAdjustLive do
  use LivepromptWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <%= if @disabled do %>
        <div><%= render_slot(@inner_block) %></div>
      <% else %>
        <div class="flex items-center gap-2">
          <button phx-click={@decrease} type="button" class="btn btn-sm">
            -
          </button>
          <%= render_slot(@inner_block) %>
          <button phx-click={@increase} type="button" class="btn btn-sm">
            +
          </button>
        </div>
      <% end %>
    </div>
    """
  end
end
