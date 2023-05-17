import { createApp, h } from 'vue'
import { createPinia } from 'pinia';
import { createInertiaApp } from '@inertiajs/vue3';
import axios from 'axios';
import ApplicationLayout from '../components/layout/ApplicationLayout.vue';
import LoginLayout from '../components/layout/LoginLayout.vue';
import Csrf from '~/utils/Csrf.js';
import Rails from '@rails/ujs';

const pages = import.meta.glob('../views/**/*.vue', { eager: true });

const layouts = {
  LoginLayout,
};

document.addEventListener('DOMContentLoaded', () => {
  Csrf.refreshToken();
  axios.defaults.headers.common['X-CSRF-Token'] = Csrf.getToken();

  Rails.start();

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
        .use(createPinia())
        .mount(el);
    },
  });
});
