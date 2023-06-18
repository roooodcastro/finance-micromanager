<template>
  <footer class="mt-auto py-3 bg-primary text-white border-0">
    <div class="container">
      <ul class="nav justify-content-center border-bottom pb-3 mb-3">
        <li
          v-for="locale in locales"
          :key="locale.locale"
          class="nav-item mx-3"
        >
          <a
            :href="`?new_locale=${locale.locale}`"
            class="nav-link text-white text-center"
          >
            {{ locale.name }}
          </a>
        </li>
      </ul>

      <p class="text-center my-0 fs-6">
        © 2023 Rodrigo Castro
      </p>
    </div>
  </footer>
</template>

<script>
import{ ref } from 'vue';

import { locales as localesApi } from '~/api';

export default {
  setup() {
    const locales = ref([]);

    localesApi.list().then(response => locales.value = response);

    return { locales };
  }
}
</script>
