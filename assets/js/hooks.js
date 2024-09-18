import {throttle} from 'lodash';
import QRCode from 'qrcode';
import NoSleep from 'nosleep.js';
import Markdownit from 'markdown-it';

const noSleep = new NoSleep();
const md = Markdownit({html: true});

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

Hooks.QRCodeRender = {
    mounted() {
        const doRender = () => {
            const options = {
                margin: 2,
            };

            const text = this.el.dataset.text;

            const handleError = error => {
                if (error) console.error(error);
            };

            QRCode.toCanvas(this.el, text, options, handleError);
        };
        doRender();
        this.handleEvent('switch_tab', () => {
            doRender();
        });
    },
};

Hooks.ControlContent = {
    mounted() {
        const doScrollEvent = throttle(percent => this.pushEvent('scroll_changed', percent), 100);
        this.el.addEventListener('scroll', e => {
            const percent =
                (e.target.scrollTop / (e.target.scrollHeight - e.target.clientHeight)) * 100;
            doScrollEvent(percent);
        });
    },
};

Hooks.ViewContent = {
    mounted() {
        let play = false;
        let lastTs;
        const doScroll = (el, speed) => {
            if (el.scrollTop > el.scrollHeight - el.clientHeight) return;
            if (play === false) return;

            requestAnimationFrame(time => {
                if (!lastTs) lastTs = time;
                const elapsed = time - lastTs;
                const delta = (speed * elapsed) / 20;
                if (delta > 1) {
                    el.scrollTop += delta;
                    lastTs = time;
                }
                doScroll(el, speed);
            });
        };
        this.handleEvent('view_content', payload => {
            const content = payload.content;
            this.el.innerHTML = md.render(content);
        });
        this.handleEvent('view_scroll_percent', payload => {
            const el = this.el;
            const percent = payload.scroll;

            el.scrollTop = (el.scrollHeight - el.clientHeight) * (percent / 100);
        });
        this.handleEvent('play', payload => {
            play = payload.play;
            if (!play) return;
            lastTs = undefined;
            doScroll(this.el, payload.speed);
        });
    },
    updated() {
        this.el.innerHTML = md.render(this.el.dataset.content);
    },
};

Hooks.DatetimeFmt = {
    mounted() {
        this.handleEvent('validate', () => {
            this.el.innerHTML = new Date().toLocaleString();
        });
        this.el.innerText = new Date(this.el.dataset.datetime).toLocaleString();
    },
};

export default Hooks;
