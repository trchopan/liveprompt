defmodule LivepromptWeb.ControlLive do
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
    <div class="pb-3 flex place-content-between">
      <.back navigate={~p"/"}>Back</.back>
      <p class="text-sm">
        Go to <.link href={~p"/view"} class="text-primary font-bold">View</.link>
      </p>
    </div>
    <div>
      <div>
        <.button type="button" phx-click="play">Play</.button>
      </div>
      <div>
        <.simple_form for={@form} phx-change="validate" phx-submit="content">
          <.input
            field={@form[:range]}
            type="range"
            min={0}
            max={100}
            step={1}
            label="Seek"
            phx-change="range"
          />
          <.input
            field={@form[:content]}
            type="textarea"
            label="Content"
            placeholder="text"
            phx-change="content"
          />
        </.simple_form>
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    socket = socket |> assign(page_title: "Control")

    if connected?(socket) do
      form =
        to_form(%{
          "content" => """
          # Iter at amantior labores oculis ostentis Iove

          ## Sic stabula relinquis premeret facta Surrentino telum

          Lorem markdownum erat longa de depulerat undis adsueto, ferre. Multa [semper
          sepulcris](http://www.locus-velamina.net/etdelubra) ad iussa praetendat venerit
          memorantur satis **inter** gemebundus est durataeque mente. Lentis inceptaque
          decus, et paelice medio postquam quandoquidem visa undique.

          ## Texit suus quoque omnia Diti tenent vitiatis

          Audita esto venenis quid cum, est cupidine, taedis veteremque tanta. Persequerer
          fundit et *suis praevia* tanta. Et illa, se magnum et Saturnia **sequemur
          moveri** maiestatemque fama caritura mortale unum. Gentis nullum ludere vixque
          appellant pellis; hic factum.

          cell += username(dvd_wrap, array + dram(-4), link);
          if (optic_server(data_troubleshooting_heuristic + plagiarism /
              publishingOle, meta_record_cd + vpnOutboxStack - bot, edi_text(4,
              routerCpa, class))) {
          website(remoteVlb(computing_function_drive, 2, ipv_microphone),
                  scarewareTelecommunicationsFrequency.secondarySurgeMpeg(
                  bridgeTracerouteBatch));
          encodingPrebindingExif.domainVlbParameter(task, syncSidebar);
          }
          storageMenu -= mirror_webmail;
          var windows = cloud_media_dithering(96, sidebar_pack) + snapshot(
              interlaced_win) + 98;

          ## Casta vos medium circumstetit tamen sacra solitos

          Geminata reliquit omnia, paterque, viri alta deo nusquam clarum non vestro
          terra, sum tibi **tibi**. Aut et anni eiectas, ora dumque timentem. Ius proles
          **refert** coercebat, at totoque Phaethontis hasta in, nostras. *Tu nullis
          Editus* superabat evaserat sanguine apris. Lustrat quam tibi, una manibus;
          victor tuorum, sit [mihi quid lacrimisque](http://instigant-obvia.org/) exiguo
          dolor?

          **Distincta** tamen pinum secundum. Helicen senserit *coniecta etiam*, flamina
          dextera et petendo supplice nomen me capacis ope volat perque.

          ## Epulis conplexibus cursu

          Ab et **spumis** usque tamen **sucis** multaque visus, **secutus voluntas**.
          Quamvis fingebam, vis nam tuorum posuere Latinas.

          Ut exigis, his in inmensum canum iam adflabitur motibus, imis instabilis omni
          thalamos vires. Flammam temptanti fontemque cervum omnia, [oriens ego
          quibus](http://medio-fama.net/natus.aspx) erat. Abstrahor alite non, nec quod
          Danais descenderat, quoque fugit *crudelia est* feras auctore! Io a artes plura
          vulgat est extulit mixtos: fortunae: mortis versasque. Artus Aurora mox maris
          hausit unde respicit narratibus viridi semper.

          Summo solida Phrygias, capillos si mentum marmore hosti Nessoque locus et in per
          quod, facta. Famaque avidas, **demersit** exiguo voce hector utque, dolores,
          quoque repetenda quis involvite. Abdita ego aura velavit hastam, ire at rostro
          creavit! Quo materno stratis crabronis Dryopen quam equo [meritis primoque
          terras](http://www.manusrhadamanthon.net/progeniemtheseus) inplet dominos, famae
          plaga nec quinque alis classe!
          """,
          "range" => 0
        })

      socket =
        socket
        |> assign(:loading, false)
        |> assign(:form, form)

      {:ok, socket, temporary_assigns: [form: form]}
    else
      {:ok, assign(socket, loading: true)}
    end
  end

  @impl true
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("play", _params, socket), do: broadcast_control(socket, :play)

  @impl true
  def handle_event("range", %{"range" => range}, socket) do
    IO.inspect(range, label: "range")
    broadcast_control(socket, {:range, String.to_integer(range)})
    {:noreply, socket}
  end

  @impl true
  def handle_event("content", %{"content" => content}, socket),
    do: broadcast_control(socket, {:content, content})

  defp broadcast_control(socket, payload) do
    Phoenix.PubSub.broadcast!(Liveprompt.PubSub, "control", payload)
    {:noreply, socket}
  end
end
