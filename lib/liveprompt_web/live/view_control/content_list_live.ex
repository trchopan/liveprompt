defmodule LivepromptWeb.ViewControl.ContentListLive do
  alias Liveprompt.ViewControls.Content
  alias LivepromptWeb.ViewControl.Components
  alias Liveprompt.ViewControls
  use LivepromptWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <div class="grid grid-cols-1 md:grid-cols-2 mt-2 gap-6">
      <div>
        <.simple_form for={@form} phx-change="validate" phx-submit="new_content">
          <.input field={@form[:name]} type="text" label="Name" />
          <.button class="btn btn-accent">
            New
          </.button>
        </.simple_form>
      </div>
      <div
        :for={content <- @contents}
        class="p-5 h-[16.5rem] border border-stone-400 rounded flex flex-col"
      >
        <% {view_link, control_link} = Components.make_view_control_links(content.id) %>
        <div class="font-bold text-sm text-stone-400 text-center border-b border-stone-400 pb-1 mb-1">
          <%= content.name %>
        </div>
        <div class="line-clamp-6">
          <%= content.content || "- Empty content -" %>
        </div>
        <div class="flex-grow"></div>
        <div class="pt-3 flex gap-2 items-center">
          <span class="text-xs text-stone-400">
            Update:
            <span
              id={"update-time-#{content.id}"}
              phx-hook="DatetimeFmt"
              data-datetime={content.updated_at}
            />
          </span>
          <div class="flex gap-2">
            <.link class="btn btn-sm btn-primary" href={view_link}>
              View
            </.link>
            <.link class="btn btn-sm btn-warning" href={control_link}>
              Control
            </.link>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    contents = ViewControls.list_contents_by_user(user)

    form =
      %Content{}
      |> ViewControls.change_content_name()
      |> to_form()

    socket =
      socket
      |> assign(:contents, contents)
      |> assign(:form, form)

    {:ok, socket}
  end

  def handle_event("validate", %{"content" => content}, socket) do
    form =
      %Content{}
      |> ViewControls.change_content_name(content)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, form: form)}
  end

  @impl true
  def handle_event("new_content", %{"content" => content}, socket) do
    user = socket.assigns.current_user

    case ViewControls.create_content_for_user(user, content) do
      {:ok, content} ->
        {_, control_link} = Components.make_view_control_links(content.id)

        {:noreply,
         socket
         |> redirect(to: control_link)}

      {:error, changeset} ->
        {:noreply,
         socket
         |> assign(:form, to_form(changeset))}
    end
  end
end
