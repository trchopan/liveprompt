import QRCode from 'qrcode';
import NoSleep from 'nosleep.js';
import {signInWithGoogle} from './signin';

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

        const host = window.location.origin;
        const uuid = this.el.dataset.uuid;

        const handleError = error => {
            if (error) console.error(error);
        };

        QRCode.toCanvas(viewCanvas, `${host}/view/${uuid}`, options, handleError);

        QRCode.toCanvas(controlCanvas, `${host}/control/${uuid}`, options, handleError);
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

Hooks.SignIn = {
    mounted() {
        this.handleEvent('sign-in', async payload => {
            const {token, user} = await signInWithGoogle();
            this.pushEvent('signed-in', {token, user});
        });
    },
};

export default Hooks;
