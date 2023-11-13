<template>
  <footer
    class="mt-auto text-white border-0"
    :class="{ 'py-3 PageFooter--background':!compact, 'py-1': compact }"
  >
    <div class="container">
      <ul
        class="nav justify-content-center border-bottom"
        :class="{ 'pb-3 mb-3': !compact, 'pb-1 mb-1': compact }"
      >
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
        © 2023 Rodrigo Castro | Version {{ version }}-{{ deployTimestamp }}
      </p>
    </div>
  </footer>
</template>

<script>
import { ref, onMounted } from 'vue';

import { locales as localesApi } from '~/api';

export default {
  props: {
    compact: {
      type: Boolean,
      default: false,
    },
  },
  setup() {
    const locales = ref([]);
    const version = ref('');
    const deployTimestamp = ref('');

    onMounted(() => {
      version.value = document.querySelector('meta[name="version"]')?.content;
      deployTimestamp.value = document.querySelector('meta[name="deploy-timestamp"]')?.content || 'latest';
    });

    localesApi.index().then(response => locales.value = response);

    return {
      locales,
      version,
      deployTimestamp,
    };
  },
}
</script>

<style lang="scss" scoped>
@import '../../stylesheets/variables';

.PageFooter--background {
  background-color: $mintgreen-700;
}
</style>
