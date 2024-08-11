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

Hooks.ViewContent = {
    mounted() {
        this.handleEvent('view_content', payload => {
            console.log('>>', payload);
            const content = payload.content;
            this.el.innerHTML = md.render(content);
        });
        this.handleEvent('view_scroll', payload => {
            console.log('>>', payload);
            const el = this.el;
            const percent = payload.scroll;

            // scroll element to percentage
            el.scrollTop = (el.scrollHeight - el.clientHeight) * (percent / 100);
        });

        this.handleEvent('view_flip', payload => {
            console.log('>>', payload);
            const el = this.el;
            if (payload.flip) {
                el.classList.add('horizontal-flip');
            } else {
                el.classList.remove('horizontal-flip');
            }
        });
    },
};

Hooks.DatetimeFmt = {
    mounted() {
        this.handleEvent('validate', () => {
            this.el.innerHTML = new Date().toLocaleString();
        });
        console.log('Heree>>', this.el.dataset);
        this.el.innerText = new Date(this.el.dataset.datetime).toLocaleString();
    },
};

export default Hooks;
