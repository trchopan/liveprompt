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
        this.handleEvent('view-content:range', payload => {
            const el = this.el;
            const percent = payload.range;
            // scroll element to percentage
            el.scrollTop = (el.scrollHeight - el.clientHeight) * (percent / 100);
        });
    },
    destroyed() {},
};

export default Hooks;
