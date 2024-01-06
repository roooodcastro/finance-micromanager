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
        {{ t('copyright_notice') }} | {{ t('version') }} {{ version }}-{{ deployTimestamp }}
      </p>

      <p class="text-center mb-0 mt-2 fs-3">
        <a
          :href="GITHUB_REPO_URL"
          class="link-light"
        >
          <FontAwesomeIcon :icon="['fab', 'github']" />
        </a>
      </p>
    </div>
  </footer>
</template>

<script>
import { ref, onMounted } from 'vue';
import { storeToRefs } from 'pinia';

import useLocaleStore from '~/stores/LocaleStore.js';
import I18n from '~/utils/I18n.js';
import { GITHUB_REPO_URL } from '~/utils/Constants.js';

import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';

export default {
  components: {
    FontAwesomeIcon,
  },

  props: {
    compact: {
      type: Boolean,
      default: false,
    },
  },
  setup() {
    const version = ref('');
    const deployTimestamp = ref('');

    onMounted(() => {
      version.value = document.querySelector('meta[name="version"]')?.content;
      deployTimestamp.value = document.querySelector('meta[name="deploy-timestamp"]')?.content || 'dev';
    });

    const { locales } = storeToRefs(useLocaleStore());

    return {
      t: I18n.scopedTranslator('views.layout.footer'),
      locales,
      version,
      deployTimestamp,
      GITHUB_REPO_URL,
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
