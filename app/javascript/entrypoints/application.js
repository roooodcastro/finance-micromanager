import { createApp, h } from 'vue'
import { createInertiaApp } from '@inertiajs/vue3';
import * as bootstrap from 'bootstrap';
import axios from 'axios';
import ApplicationLayout from '../components/layout/ApplicationLayout.vue';
import LoginLayout from '../components/layout/LoginLayout.vue';
import Csrf from '~/utils/Csrf.js';

const pages = import.meta.glob('../views/**/*.vue', { eager: true });

const layouts = {
  LoginLayout,
};

document.addEventListener('DOMContentLoaded', () => {
  Csrf.refreshToken();
  axios.defaults.headers.common['X-CSRF-Token'] = Csrf.getToken();


  createInertiaApp({
    id: 'app',
    resolve: async name => {
      const page = pages[`../views/${name}.vue`].default;
      page.layout = layouts[page.layout] || page.layout || ApplicationLayout;

      return page;
    },
    setup({ el, App, props, plugin }) {
      createApp({ render: () => h(App, props) })
        .use(plugin)
        .mount(el);
    },
  });
});
