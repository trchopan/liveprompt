import QRCode from 'qrcode';
import NoSleep from 'nosleep.js';

const noSleep = new NoSleep();

const Hooks = {};

Hooks.LightOut = {
    mounted() {
        document.body.classList.add('lightout');
        noSleep.enable();
    },
    destroyed() {
        document.body.classList.remove('lightout');
        noSleep.disable();
    },
};

Hooks.QRCodeModal = {
    mounted() {
        const viewBtn = document.getElementById('qr-code-view');
        const viewCanvas = document.getElementById('view-qr');
        const controlBtn = document.getElementById('qr-code-control');
        const controlCanvas = document.getElementById('control-qr');

        const setActive = (btnEl, canvasEl, mode) => {
            if (mode === false) {
                btnEl.classList.remove('tab-active');
                canvasEl.classList.remove('block');
                canvasEl.classList.add('hidden');
            } else {
                btnEl.classList.add('tab-active');
                canvasEl.classList.add('block');
                canvasEl.classList.remove('hidden');
            }
        };

        viewBtn.addEventListener('click', () => {
            setActive(viewBtn, viewCanvas, true);
            setActive(controlBtn, controlCanvas, false);
        });

        controlBtn.addEventListener('click', () => {
            setActive(viewBtn, viewCanvas, false);
            setActive(controlBtn, controlCanvas, true);
        });

        const options = {
            margin: 2,
        };

        const uuid = this.el.dataset.uuid;
        const host = window.location.origin;

        QRCode.toCanvas(viewCanvas, `${host}/view/${uuid}`, options, function (error) {
            if (error) console.error(error);
        });

        QRCode.toCanvas(controlCanvas, `${host}/control/${uuid}`, options, function (error) {
            if (error) console.error(error);
        });
    },
};

Hooks.ViewContent = {
    mounted() {
        this.handleEvent('view:range', payload => {
            const el = this.el;
            const percent = payload.range;
            // scroll element to percentage
            el.scrollTop = (el.scrollHeight - el.clientHeight) * (percent / 100);
        });

        this.handleEvent('view:flip', payload => {
            const el = this.el;
            if (payload.flip) {
                el.classList.add('horizontal-flip');
            } else {
                el.classList.remove('horizontal-flip');
            }
        });
    },
    destroyed() {},
};

Hooks.ControlPlayButton = {
    mounted() {
        let playInterval = null;

        this.handleEvent('control:play', payload => {
            if (payload.play === false) {
                clearInterval(playInterval);
                return;
            }
            const el = document.getElementById('control-range');

            playInterval = setInterval(() => {
                el.value = +el.value + payload.speed;
                if (el.value >= 100) {
                    this.pushEvent('play', {play: false});
                } else {
                    this.pushEvent('range', {range: el.value});
                }
            }, payload.tick);
        });
    },
};

export default Hooks;
