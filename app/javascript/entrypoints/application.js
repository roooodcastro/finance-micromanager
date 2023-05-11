// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
// import "@hotwired/turbo-rails"
import { createApp, h } from 'vue'
import { createInertiaApp } from '@inertiajs/vue3';
import { InertiaProgress } from '@inertiajs/progress';
// import axios from 'axios';
import ApplicationLayout from '../components/ApplicationLayout.vue';

const pages = import.meta.glob('../views/**/*.vue', { eager: true });

document.addEventListener('DOMContentLoaded', () => {
  // const csrfToken = document.querySelector('meta[name=csrf-token]').content;
  // axios.defaults.headers.common['X-CSRF-Token'] = csrfToken;


  InertiaProgress.init();

  createInertiaApp({
    resolve: async name => {
      const page = (await pages[`../views/${name}.vue`]).default;
      page.layout = page.layout || ApplicationLayout;

      return page
    },
    setup({ el, App, props, plugin }) {
      createApp({ render: () => h(App, props) })
        .use(plugin)
        .mount(el);
    },
  })
});
