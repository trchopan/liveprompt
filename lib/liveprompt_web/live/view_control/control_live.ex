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

        <button
          phx-click="flip"
          type="button"
          class={"btn btn-sm " <> if @flip, do: "btn-warning", else: ""}
        >
          Flip
        </button>

        <Components.value_adjust
          disabled={@play}
          display={"Speed: #{@speed} %"}
          value={@speed}
          step={@speed_step}
          change_event="speed_changed"
        />

        <Components.value_adjust
          disabled={@play}
          display={"Tick: #{@tick} s"}
          value={@tick}
          step={@tick_step}
          change_event="tick_changed"
        />
      </div>
      <div>
        <.simple_form for={@scroll_form}>
          <.input
            field={@scroll_form[:value]}
            type="range"
            min={0.0}
            max={100.0}
            step={0.2}
            label="Seek"
            phx-change="scroll_changed"
          />
        </.simple_form>
      </div>
      <div>
        <.simple_form for={@form} id="controller_form" phx-change="validate" phx-submit="save">
          <%= if @current_user != nil do %>
            <.input field={@form[:name]} type="text" label="Name" placeholder="Name" />
          <% end %>
          <.input
            field={@form[:content]}
            type="textarea"
            rows="10"
            label="Content"
            placeholder="Content"
          />
          <%= if @current_user != nil do %>
            <.button type="submit">Save</.button>
          <% end %>
        </.simple_form>
      </div>
    </div>
    """
  end

  @impl true
  def mount(%{"content_id" => content_id}, _session, socket) do
    socket = socket |> assign(page_title: "Control")

    if connected?(socket) do
      maybe_socket =
        {:ok, socket}
        |> Components.check_invalid_content_id(content_id)
        |> Components.check_content_is_found(content_id)
        |> Components.check_content_is_private(
          socket.assigns.current_user,
          fallback_content(content_id)
        )

      case maybe_socket do
        {:error, socket} ->
          {:ok, socket}

        {:ok, socket} ->
          {:ok, mount_with_content(socket)}
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

  defp mount_with_content(socket) do
    content = socket.assigns.content
    content_changeset = Content.changeset(content)

    socket
    |> assign(:loading, false)
    |> assign(:form, to_form(content_changeset, as: "content"))
    |> assign(:scroll_form, to_form(%{"value" => 0.0}))
    |> assign(:play, false)
    |> assign(:flip, false)
    # How many percentage to move per tick
    |> assign(:speed, 2.0)
    |> assign(:speed_step, 0.5)
    # How fast in ms should the view tick
    |> assign(:tick, 0.5)
    |> assign(:tick_step, 0.5)
  end

  @impl true
  def handle_event("save", %{"content" => content_params}, socket) do
    content = socket.assigns.content

    case ViewControls.update_content(content, content_params) do
      {:ok, _} ->
        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
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
    {:noreply, assign(socket, speed: limit_range_value(speed, 1.0, 5.0))}
  end

  @impl true
  def handle_event("tick_changed", %{"value" => tick}, socket) do
    {:noreply, assign(socket, tick: limit_range_value(tick, 0.5, 2))}
  end

  @impl true
  def handle_event("flip", _params, socket) do
    flip = !socket.assigns.flip
    socket = socket |> broadcast_control({:flip, flip}) |> assign(:flip, flip)
    {:noreply, socket}
  end

  @impl true
  def handle_event("scroll_changed", %{"value" => scroll}, socket) do
    {scroll, _} = Float.parse(scroll)

    socket =
      socket
      |> assign(:scroll_form, to_form(%{"value" => scroll}))
      |> broadcast_control({:scroll, scroll})

    {:noreply, socket}
  end

  @impl true
  def handle_event("play", _params, socket) do
    play = !socket.assigns.play

    if play do
      Kernel.send(self(), :do_tick)
    end

    {:noreply, assign(socket, play: play)}
  end

  @impl true
  def handle_info(:do_tick, socket) do
    play = socket.assigns.play
    IO.inspect(play, label: "PLAY")

    if play do
      tick = socket.assigns.tick
      speed = socket.assigns.speed
      scroll = socket.assigns.scroll_form.params["value"] + speed

      socket =
        socket
        |> assign(:scroll_form, to_form(%{"value" => scroll}))
        |> assign(:play, scroll < 100.0)
        |> broadcast_control({:scroll, scroll})

      :timer.send_after(round(tick * 1000), self(), :do_tick)

      {:noreply, socket}
    else
      {:noreply, socket}
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

  defp fallback_content(content_id) do
    %Content{
      id: content_id,
      name: "Public",
      content: Components.lorem_content()
    }
  end
end
