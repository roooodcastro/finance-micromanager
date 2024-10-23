<template>
  <footer
    class="PageFooter mt-auto text-white border-0"
    :class="{ 'py-3 PageFooter--background':!compact, 'py-1': compact }"
  >
    <div class="container">
      <div
        class="d-flex gap-3 align-items-center justify-content-center border-bottom border-primary"
        :class="{ 'pb-3 mb-3': !compact, 'pb-1 mb-1': compact }"
      >
        <ul class="nav justify-content-center align-items-center">
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

        <ColorModeSelect />
      </div>

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

import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';

import useLocaleStore from '~/stores/LocaleStore.js';
import I18n from '~/utils/I18n.js';
import { GITHUB_REPO_URL } from '~/utils/Constants.js';

import ColorModeSelect from '~/components/layout/ColorModeSelect.vue';

export default {
  components: {
    ColorModeSelect,
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

.PageFooter {
  height: $page-footer-height;
}

.PageFooter--background {
  background-color: $mintgreen-700;
}

@include color-mode(dark) {
  .PageFooter--background {
  background-color: $mintgreen-800;
}
}
</style>
