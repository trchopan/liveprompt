defmodule LivepromptWeb.ControlLive do
  require Logger
  alias Liveprompt.ViewControls
  alias Liveprompt.ViewControls.Content
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
    <div>
      <Components.top_view_control
        current_user={@current_user}
        content_id={@content.id}
        is_control={true}
      />
      <div class="pb-3 grid grid-cols-2 md:grid-cols-4 items-center justify-center gap-3">
        <button
          phx-click="play"
          type="button"
          class={"btn btn-sm " <> if @play, do: "btn-warning", else: ""}
        >
          Play
        </button>

        <Components.value_adjust
          disabled={@play}
          display={"Speed: #{@speed}"}
          reduce={JS.push("speed_changed", value: %{value: @speed - 0.5})}
          increase={JS.push("speed_changed", value: %{value: @speed + 0.5})}
        />

        <button
          phx-click="flip"
          type="button"
          class={"btn btn-sm " <> if @flip, do: "btn-warning", else: ""}
        >
          Flip
        </button>

        <Components.value_adjust
          display={"Size: #{map_size_text(@size)}"}
          reduce={JS.push("size_changed", value: %{value: @size - 1})}
          increase={JS.push("size_changed", value: %{value: @size + 1})}
        />
      </div>
      <div>
        <.simple_form for={@form} id="controller_form" phx-change="validate" phx-submit="save">
          <%= if @current_user != nil do %>
            <.input field={@form[:name]} type="text" label="Name" placeholder="Name" />
          <% end %>
          <.input
            id="control-content"
            phx-hook="ControlContent"
            field={@form[:content]}
            type="textarea"
            rows="10"
            label="Content - Scroll the content to scroll the view"
            placeholder="Content"
            id="control-content-inner"
          />
          <div class="flex">
            <.button type="submit">Save</.button>
            <div class="flex-grow"></div>
            <%= if @current_user != nil do %>
              <.button
                type="button"
                class="btn btn-square btn-outline"
                phx-click="delete"
                data-confirm="Are you sure?"
              >
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  class="h-6 w-6"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke="currentColor"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M6 18L18 6M6 6l12 12"
                  />
                </svg>
              </.button>
            <% end %>
          </div>
        </.simple_form>
      </div>
    </div>
    """
  end

  @impl true
  def mount(%{"content_id" => content_id}, _session, socket) do
    socket =
      socket
      |> assign(page_title: "Control")
      |> assign(content_id: content_id)

    if connected?(socket) do
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

  @impl true
  def mount(_params, _session, socket) do
    content_id = Ecto.UUID.generate()
    {:ok, redirect(socket, to: ~p"/controls/#{content_id}")}
  end

  defp mount_ui(socket) do
    content = socket.assigns.content
    content_changeset = Content.changeset(content)

    socket
    |> assign(:loading, false)
    |> assign(:form, to_form(content_changeset, as: "content"))
    |> assign(:play, false)
    |> assign(:flip, false)
    |> assign(:size, 0)
    # How many percent to move per tick
    |> assign(:speed, 1.0)
  end

  @impl true
  def handle_event("save", %{"content" => content_params}, socket) do
    content = socket.assigns.content

    case ViewControls.update_content(content, content_params) do
      {:ok, content} ->
        {:noreply, socket |> assign(content: content)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(form: to_form(changeset))}
    end
  end

  @impl true
  def handle_event("validate", %{"content" => content_params}, socket) do
    content = socket.assigns.content
    changeset = ViewControls.change_content(content, content_params)

    if changeset.valid?() do
      broadcast_control(
        socket,
        {
          :content,
          %Content{
            id: content.id,
            name: content.name,
            content: content_params["content"]
          }
        }
      )
    end

    form =
      changeset
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, form: form)}
  end

  @impl true
  def handle_event("speed_changed", %{"value" => speed}, socket) do
    {:noreply, assign(socket, speed: limit_range_value(speed, 0.5, 3.0))}
  end

  @impl true
  def handle_event("size_changed", %{"value" => size}, socket) do
    new_size = limit_range_value(size, 0, 2)

    socket =
      socket |> assign(size: new_size) |> broadcast_control({:size, new_size})

    {:noreply, socket}
  end

  @impl true
  def handle_event("flip", _params, socket) do
    flip = !socket.assigns.flip
    socket = socket |> assign(:flip, flip) |> broadcast_control({:flip, flip})
    {:noreply, socket}
  end

  @impl true
  def handle_event("scroll_changed", scroll, socket) do
    socket =
      socket
      |> broadcast_control({:scroll, scroll})

    {:noreply, socket}
  end

  @impl true
  def handle_event("play", _params, socket) do
    play = !socket.assigns.play

    broadcast_control(
      socket,
      {:play, %{play: play, speed: socket.assigns.speed}}
    )

    {:noreply, assign(socket, play: play)}
  end

  @impl true
  def handle_event("delete", _params, socket) do
    content = socket.assigns.content

    if content.user_id == nil do
      socket =
        socket
        |> put_flash(:error, "Cannot delete public content.")

      {:noreply, socket}
    else
      {:ok, _} = ViewControls.delete_content(content)
      {:noreply, socket |> redirect(to: ~p"/contents")}
    end
  end

  defp broadcast_control(socket, payload) do
    content_id = socket.assigns.content.id

    case Phoenix.PubSub.broadcast(Liveprompt.PubSub, "control" <> content_id, payload) do
      {:error, err} ->
        Logger.error("Error broadcast control event", %{err: err})
        socket |> put_flash(:error, "Failed to broadcast control event")

      :ok ->
        socket
    end
  end

  defp limit_range_value(value, min, max) do
    new_value = if is_float(value), do: Float.round(value, 2), else: value

    cond do
      new_value < min ->
        min

      new_value > max ->
        max

      true ->
        new_value
    end
  end

  defp map_size_text(0), do: "base"
  defp map_size_text(1), do: "medium"
  defp map_size_text(2), do: "large"
end
