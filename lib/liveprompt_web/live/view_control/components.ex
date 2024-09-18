defmodule LivepromptWeb.ViewControl.Components do
  alias Liveprompt.ViewControls
  use LivepromptWeb, :html
  use LivepromptWeb, :live_view

  def view_instruction do
    """
    <h1>See the introduction video</h1>
    <p>
      <a href="#{Const.encode(:youtube_introduction_video)}">Liveprompt Introduction</a>
    </p>
    <h1>How to use the app</h1>
    <p>You can edit this content in the <span class="text-warning font-bold">Control</span> panel.</p>
    <p>This application is intended to be used with <u>two devices</u>. One device serves as the Control, while the other functions as the View.</p>
    <p>Changes made to the content of the Control will be immediately reflected in the View.</p>
    <p>The Control and View listen to each other via the unique <span class="text-pink-400 font-bold">ID</span>.</p>
    """
  end

  @doc """
  Render the top section of the view or control page.
  Includes:
  - Back button
  - QR scan modal
  - Link to switch between view and control pages

  ## Example

      <.top_view_control
        current_user={@current_user}
        content_id={@content.id}
        is_control={false}
      />
  """
  attr :current_user, :map, required: true
  attr :content_id, :string, required: true
  attr :is_control, :boolean, required: true

  def top_view_control(assigns) do
    content_id = assigns.content_id
    {view_link, control_link} = make_view_control_links(content_id)
    assigns = assigns |> assign(view_link: view_link, control_link: control_link)

    ~H"""
    <div class="pb-2 grid grid-cols-2 md:grid-cols-[auto,1fr,auto] place-content-between">
      <.back navigate={if @current_user, do: ~p"/contents", else: ~p"/"}>Back</.back>
      <div class="order-last col-span-2 md:order-none md:col-span-1 md:grow flex items-center place-content-between md:justify-center gap-2">
        <p class="text-xs"><span class="text-pink-400 font-bold">ID:</span> <%= @content_id %></p>
        <.live_component
          module={LivepromptWeb.ViewControl.QrcodeLive}
          id="qr-code-live"
          view_link={@view_link}
          control_link={@control_link}
        />
      </div>
      <p class="text-right text-sm">
        Go to
        <%= if @is_control do %>
          <.link href={@view_link} class="text-primary font-bold">
            View
          </.link>
        <% else %>
          <.link href={@control_link} class="text-warning font-bold">
            Control
          </.link>
        <% end %>
      </p>
    </div>
    """
  end

  @doc """
  Value adjust component with 2 buttons, minus and plus with a value in middle.

  ## Example

        <.value_adjust
          disabled={@play}
          display={"Speed: {@speed} %"}
          value={@speed}
          step={@speed_step}
          change_event="speed_changed"
        />
  """
  attr :disabled, :boolean, default: false
  attr :display, :string, required: true
  attr :increase, JS, required: true
  attr :reduce, JS, required: true

  def value_adjust(assigns) do
    ~H"""
    <div class="flex items-center justify-center">
      <%= if @disabled do %>
        <div class="text-sm"><%= @display %></div>
      <% else %>
        <div class="flex items-center gap-2">
          <button phx-click={JS.exec(@reduce, "", to: "#noop")} type="button" class="btn btn-sm">
            -
          </button>
          <div class="text-sm"><%= @display %></div>
          <button phx-click={JS.exec(@increase, "", to: "#noop")} type="button" class="btn btn-sm">
            +
          </button>
        </div>
      <% end %>
    </div>
    """
  end

  @doc """
  Format the datetime in local format.

  ## Example

        <.datetime_local_fmt
          id="some_id"
          dt={udpated_at}
        />
  """
  attr :id, :string, required: true
  attr :dt, :any, required: true

  def datetime_local_fmt(assigns) do
    ~H"""
    <span id={@id} phx-hook="DatetimeFmt" data-datetime={@dt}>
      <%= @dt || "" %>
    </span>
    """
  end

  def make_view_control_links(content_id) do
    {~p"/views/#{content_id}", ~p"/controls/#{content_id}"}
  end

  def check_invalid_content_id(socket) do
    content_id = socket.assigns.content_id

    case Ecto.UUID.cast(content_id) do
      :error ->
        {:error, socket, :bad_content_id}

      {:ok, _} ->
        {:ok, socket}
    end
  end

  def assign_content(socket) do
    content_id = socket.assigns.content_id

    case ViewControls.get_content(content_id) do
      nil ->
        {:error, assign(socket, content: nil), :not_found_content}

      content ->
        {:ok, assign(socket, content: content)}
    end
  end

  def check_user_is_owner(socket) do
    content = socket.assigns.content
    current_user = socket.assigns.current_user

    case {content.user_id, current_user} do
      {nil, _} ->
        # Content is public, any user can read
        {:ok, socket}

      {_, nil} ->
        # Public user trying to access private content
        {:error, socket, :user_is_not_content_owner}

      {c_user_id, current_user} ->
        if c_user_id != current_user.id do
          {:error, socket, :user_is_not_content_owner}
        else
          {:ok, socket}
        end
    end
  end

  def handle_bad_content_id(socket) do
    socket
    |> put_flash(:error, "Bad content id format")
    |> redirect(to: ~p"/")
  end

  def handle_not_found_content(socket) do
    current_user = socket.assigns.current_user

    if current_user == nil do
      {:ok, content} = ViewControls.create_public_content(view_instruction())

      socket
      |> put_flash(:info, "New content created")
      |> redirect(to: ~p"/controls/#{content.id}")
    else
      socket
      |> put_flash(:error, "Not found content or content not belong to you")
      |> redirect(to: ~p"/contents")
    end
  end

  def handle_user_is_not_content_owner(socket) do
    redirect_to = if socket.assigns.current_user == nil, do: ~p"/", else: ~p"/contents"

    socket
    |> put_flash(:error, "Content is private")
    |> redirect(to: redirect_to)
  end
end
