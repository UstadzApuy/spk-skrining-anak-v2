import './bootstrap';

import { createApp, h } from 'vue';
import { createInertiaApp } from '@inertiajs/vue3';
import { useTheme } from './Composables/useTheme';

createInertiaApp({
    resolve: (name) => {
        const pages = import.meta.glob('./Pages/**/*.vue', { eager: true });

        return pages[`./Pages/${name}.vue`];
    },

    setup({ el, App, props, plugin }) {
        const { initTheme } = useTheme();
        initTheme();

        createApp({
            render: () => h(App, props),
        })
            .use(plugin)
            .mount(el);
    },
});