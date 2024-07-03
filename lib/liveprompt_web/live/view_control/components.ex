defmodule LivepromptWeb.ViewControl.Components do
  alias Liveprompt.ViewControls
  use LivepromptWeb, :html
  use LivepromptWeb, :live_view

  def lorem_content do
    """
    # Ora reliquit memorant saepe referuntur

    ## Cristis duarum

    Lorem markdownum ab *silicem* Herculea eratque ingratos, ubi claudor dentes,
    refers tepentibus mori, [illi laedor est](http://trahentisolidumve.org/illis)
    silva. Fixit aliquam numerumque Phoceus modum solvit tigres oscula fallacia
    fluentia, **exciderit**! Fatur fata pete Theseus, spatiosum quamvis.

    Leto Ceres data, adest adsimilare infitiatur Troica necis, terribilesque mecum
    prosiliunt nimius subitis miseram. Esse
    [colubrae](http://achilles-frequento.com/adfectus-ingeniis) ore inde,
    stagnumque, mihi erat corpora. Undas prius non non vix autumni, sors, **una
    anima hunc** amplexo, Finierat *egredior*.

    ## Errare alta tibi ales inde mundus

    Herbae carmine Mavortis aquas: apud nec movisse acer liquores mavult. Esto
    imitata [Iovisque](http://credar.net/piscibus-aeneaden), humili tibi genetrix
    in, lexque non mihi fulmen, fertur tibi famularia.

    ripping_balancing_macro += ftpEup * 1;
    switchPim(snow_sql, 5 + pitch - mapSuperscalar, 5 - operating_backbone -
    inkjet_wi_cifs);
    dualFlops = phpIcqVolume;
    var ram = 91;
    cd_vertical(basic);

    ## Manu soporem quoque et tosti lavere denique

    Cum multi Alcyonen digiti: versus: viae sacra Tegeaea aperit starent ignesque,
    Iliacas increvisse **parte potuitque**. Petent inpia; imber sint, intus modo
    pectora patefecit percusso.

    1. Solus est metu reponunt
    2. Querellae solum
    3. Figere nec summa

    Et oscula tali gravis deficiunt nigra ea dedisti suffusus verba exilio toros
    maeonis prima contudit sollerti? Tamen mox breve vaccae in non mea mater putares
    et natas cacumine adfixa suo fecit **frustra protinus**.
    """
  end

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

  def value_adjust(assigns) do
    ~H"""
    <div class="flex items-center justify-center">
      <%= if @disabled do %>
        <div class="text-sm"><%= @display %></div>
      <% else %>
        <div class="flex items-center gap-2">
          <button
            phx-click={JS.push(@change_event, value: %{value: @value - @step})}
            type="button"
            class="btn btn-sm"
          >
            -
          </button>
          <div class="text-sm"><%= @display %></div>
          <button
            phx-click={JS.push(@change_event, value: %{value: @value + @step})}
            type="button"
            class="btn btn-sm"
          >
            +
          </button>
        </div>
      <% end %>
    </div>
    """
  end

  def make_view_control_links(content_id) do
    {~p"/views/#{content_id}", ~p"/controls/#{content_id}"}
  end

  def check_invalid_content_id(maybe_socket, content_id) do
    case maybe_socket do
      {:error, socket} ->
        {:error, socket}

      {:ok, socket} ->
        case Ecto.UUID.cast(content_id) do
          :error ->
            {:error,
             socket
             |> put_flash(:error, "Bad content id format")
             |> redirect(to: ~p"/")}

          {:ok, _} ->
            {:ok, socket}
        end
    end
  end

  def check_content_is_found(maybe_socket, content_id) do
    case maybe_socket do
      {:error, socket} ->
        {:error, socket}

      {:ok, socket} ->
        content = ViewControls.get_content(content_id)
        {:ok, assign(socket, content: content)}
    end
  end

  def check_content_is_private(maybe_socket, user, fallback_content) do
    case maybe_socket do
      {:error, socket} ->
        {:error, socket}

      {:ok, socket} ->
        content = socket.assigns.content

        case {user, content} do
          # Does not have user or content, it is public access
          {nil, nil} ->
            {:ok, assign(socket, content: fallback_content)}

          # Has user but not content, private access but not found content
          {_, nil} ->
            {
              :error,
              socket
              |> put_flash(:error, "Not found content")
              |> redirect(to: ~p"/contents")
            }

          {user, content} ->
            if user == nil || user.id != content.user_id do
              # Content does not belong to user
              {
                :error,
                socket
                |> put_flash(:error, "Content is private")
                |> redirect(to: ~p"/users/log_in")
              }
            else
              {:ok, assign(socket, content: content)}
            end
        end
    end
  end
end
