import { createApp, h } from 'vue'
import { createPinia } from 'pinia';
import { createInertiaApp } from '@inertiajs/vue3';
import axios from 'axios';
import ApplicationLayout from '../components/layout/ApplicationLayout.vue';
import LoginLayout from '../components/layout/LoginLayout.vue';
import Csrf from '~/utils/Csrf.js';
import I18n from '~/utils/I18n.js';
import Rails from '@rails/ujs';

import '~/utils/fontAwesome.js';

/* eslint-disable-next-line no-unused-vars */
import * as bootstrap from 'bootstrap';

const pages = import.meta.glob('../views/**/*.vue', { eager: true });

const layouts = {
  LoginLayout,
};

async function startApplication() {
  Csrf.refreshToken();
  await I18n.loadTranslations();
  axios.defaults.headers.common['X-CSRF-Token'] = Csrf.getToken();

  if (!window._rails_loaded) {
    Rails.start();
  }

  createInertiaApp({
    id: 'app',
    resolve: async name => {
      const page = pages[`../views/${name}.vue`].default;
      page.layout = layouts[page.layout] || page.layout || ApplicationLayout;

      return page;
    },
    setup({ el, App, props, plugin }) {
      // eslint-disable-next-line vue/component-api-style
      createApp({ render: () => h(App, props) })
        .use(plugin)
        .use(createPinia())
        .mount(el);
    },
  });
}

document.addEventListener('DOMContentLoaded', () => {
  startApplication();
});
