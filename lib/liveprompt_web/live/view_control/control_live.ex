defmodule LivepromptWeb.ControlLive do
  use LivepromptWeb, :live_view

  @speed_step 0.2
  @tick_step 100

  @default_content """
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
      <div class="pb-3 flex place-content-between">
        <.back navigate={~p"/"}>Back</.back>
        <p><span class="text-pink-400 font-bold">ID:</span> <%= @uuid %></p>
        <p class="text-sm">
          Go to <.link href={~p"/view/#{@uuid}"} class="text-primary font-bold">View</.link>
        </p>
      </div>
      <div class="pb-3 flex justify-center gap-3">
        <.button
          id="control-play-button"
          phx-hook="ControlPlayButton"
          phx-click="play"
          type="button"
          class={"btn-sm " <> if @play, do: "btn-warning", else: ""}
        >
          Play
        </.button>

        <.live_component
          module={LivepromptWeb.ViewControl.ValueAdjustLive}
          id="adjust-speed"
          disabled={@play == true}
          step={0.2}
          decrease="decrease-speed"
          increase="increase-speed"
        >
          <div>Speed: <%= @speed %> %</div>
        </.live_component>

        <.live_component
          module={LivepromptWeb.ViewControl.ValueAdjustLive}
          id="adjust-tick"
          disabled={@play == true}
          step={100}
          decrease="decrease-tick"
          increase="increase-tick"
        >
          <div>Tick: <%= @tick %> ms</div>
        </.live_component>
      </div>
      <div>
        <div>
          <.simple_form for={@form} phx-change="validate" phx-submit="content">
            <.input
              id="control-range"
              field={@form[:range]}
              type="range"
              min={0.0}
              max={100.0}
              step={0.2}
              label="Seek"
              phx-change="range"
            />
            <.input
              field={@form[:content]}
              type="textarea"
              rows="10"
              label="Content"
              placeholder="text"
              phx-change="content"
            />
          </.simple_form>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def mount(%{"uuid" => uuid}, _session, socket) do
    socket =
      socket
      |> assign(page_title: "Control")
      |> assign(uuid: uuid)

    if connected?(socket) do
      form =
        to_form(%{
          "content" => @default_content,
          "range" => 0
        })

      socket =
        socket
        |> assign(:loading, false)
        |> assign(:play, false)
        |> assign(:tick, 500)
        |> assign(:speed, 0.5)
        |> assign(:range, 0)
        |> assign(:form, form)

      {:ok, socket, temporary_assigns: [form: form]}
    else
      {:ok, assign(socket, loading: true)}
    end
  end

  @impl true
  def mount(_params, _session, socket) do
    uuid = Ecto.UUID.generate()
    {:ok, redirect(socket, to: ~p"/control/#{uuid}")}
  end

  @impl true
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("decrease-speed", _params, socket) do
    speed = change_value(socket.assigns.speed, -@speed_step, 0.0, 5.0)
    {:noreply, assign(socket, :speed, speed)}
  end

  @impl true
  def handle_event("increase-speed", _params, socket) do
    speed = change_value(socket.assigns.speed, +@speed_step, 0.0, 5.0)
    {:noreply, assign(socket, :speed, speed)}
  end

  @impl true
  def handle_event("decrease-tick", _params, socket) do
    tick = change_value(socket.assigns.tick, -@tick_step, 100, 2000)
    {:noreply, assign(socket, :tick, tick)}
  end

  @impl true
  def handle_event("increase-tick", _params, socket) do
    tick = change_value(socket.assigns.tick, +@tick_step, 100, 2000)
    {:noreply, assign(socket, :tick, tick)}
  end

  @impl true
  def handle_event("play", _params, socket) do
    play = !socket.assigns.play
    speed = socket.assigns.speed
    tick = socket.assigns.tick

    socket =
      socket
      |> push_event("control:play", %{play: play, speed: speed, tick: tick})
      |> assign(:play, play)

    {:noreply, socket}
  end

  @impl true
  def handle_event("range", %{"range" => range}, socket) do
    {range, _} = Float.parse(range)

    socket =
      socket
      |> broadcast_control({:range, range})
      |> assign(:range, range)

    {:noreply, socket}
  end

  @impl true
  def handle_event("content", %{"content" => content}, socket),
    do: {:noreply, broadcast_control(socket, {:content, content})}

  defp broadcast_control(socket, payload) do
    uuid = socket.assigns.uuid
    Phoenix.PubSub.broadcast!(Liveprompt.PubSub, "control" <> uuid, payload)
    socket
  end

  defp change_value(value, change, min, max) do
    new_value = value + change
    new_value = if is_float(value), do: Float.round(new_value, 2), else: new_value

    if min <= new_value and new_value <= max do
      new_value
    else
      value
    end
  end
end
