<template>
  <div class="dropdown">
    <button
      class="btn btn-xs btn-outline-light dropdown-toggle"
      type="button"
      data-bs-toggle="dropdown"
      aria-expanded="false"
    >
      <FontAwesomeIcon
        :icon="currentModeIcon"
        size="lg"
        class="me-2"
      />
      {{ t(currentMode) }}
    </button>
    <ul class="dropdown-menu">
      <li>
        <a
          class="dropdown-item"
          href="#"
          @click="setColorTheme('light')"
        >
          <FontAwesomeIcon
            :icon="['far', 'sun']"
            size="lg"
            class="me-2"
          />
          {{ t('light') }}
        </a>
      </li>
      <li>
        <a
          class="dropdown-item"
          href="#"
          @click="setColorTheme('dark')"
        >
          <FontAwesomeIcon
            :icon="['far', 'moon']"
            size="lg"
            class="me-2"
          />
          {{ t('dark') }}
        </a>
      </li>
    </ul>
  </div>
</template>

<script>
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';
import { computed, ref } from 'vue';

import I18n from '~/utils/I18n.js';
import { getColorTheme, setColorTheme } from '~/utils/ColorThemeUtils.js';

export default {
  components: {
    FontAwesomeIcon,
  },

  setup() {
    const t = I18n.scopedTranslator('views.layout.color_modes');

    const currentMode = ref(getColorTheme());
    setColorTheme(currentMode.value);

    const icons = {
      'light': ['far', 'sun'],
      'dark': ['far', 'moon'],
    };

    const currentModeIcon = computed(() => icons[currentMode.value]);

    return {
      t,
      currentMode,
      currentModeIcon,
      setColorTheme,
    };
  },
};
</script>
