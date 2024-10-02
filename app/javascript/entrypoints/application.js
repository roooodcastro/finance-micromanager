import { createApp, h } from 'vue'
import { createPinia } from 'pinia';
import { createInertiaApp } from '@inertiajs/vue3';
import axios from 'axios';
import hotkeys from 'hotkeys-js';
import ApplicationLayout from '../components/layout/ApplicationLayout.vue';
import LoginLayout from '../components/layout/LoginLayout.vue';
import Csrf from '~/utils/Csrf.js';
import I18n from '~/utils/I18n.js';
import Rails from '@rails/ujs';
import dayjs from 'dayjs';
import localizedFormat  from 'dayjs/plugin/localizedFormat.js';
import utc  from 'dayjs/plugin/utc.js';
import timezone  from 'dayjs/plugin/timezone.js';
import 'dayjs/locale/pt-br.js';
import 'dayjs/locale/en-gb.js';

import '~/utils/fontAwesome.js';
import '~/utils/JsFromRoutesConfig.js';
import { registerServiceWorker } from '~/pwa/registerWorker.js';

/* eslint-disable-next-line no-unused-vars */
import * as bootstrap from 'bootstrap';

const pages = import.meta.glob('../views/**/*.vue', { eager: true });

const layouts = {
  LoginLayout,
};

async function startApplication() {
  registerServiceWorker();

  Csrf.refreshToken();
  await I18n.loadTranslations();

  // Use en-GB locale for DayJS because mm/dd/yyyy is stupid and wrong.
  const localeForDayJs = I18n.getLocale() === 'en' ? 'en-gb' : I18n.getLocale();
  dayjs.locale(localeForDayJs);
  dayjs.extend(localizedFormat);
  dayjs.extend(utc);
  dayjs.extend(timezone);

  axios.defaults.headers.common['X-CSRF-Token'] = Csrf.getToken();

  // Allow shortcuts to be called everywhere, including input elements
  hotkeys.filter = () => true;

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
