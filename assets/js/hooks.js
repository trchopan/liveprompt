const Hooks = {};

Hooks.LightOut = {
    mounted() {
        document.body.classList.add('lightout');
    },
    destroyed() {
        document.body.classList.remove('lightout');
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
