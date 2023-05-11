import { createApp, h } from 'vue'
import { createInertiaApp } from '@inertiajs/vue3';
import * as bootstrap from 'bootstrap';
import axios from 'axios';
import ApplicationLayout from '../components/layout/ApplicationLayout.vue';

const pages = import.meta.glob('../views/**/*.vue', { eager: true });

document.addEventListener('DOMContentLoaded', () => {
  const csrfToken = document.querySelector('meta[name=csrf-token]').content;
  axios.defaults.headers.common['X-CSRF-Token'] = csrfToken;

  createInertiaApp({
    id: 'app',
    resolve: async name => {
      const page = pages[`../views/${name}.vue`].default;
      page.layout = page.layout || ApplicationLayout;

      return page;
    },
    setup({ el, App, props, plugin }) {
      createApp({ render: () => h(App, props) })
        .use(plugin)
        .mount(el);
    },
  });
});
