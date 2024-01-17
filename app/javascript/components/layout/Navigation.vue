<template>
  <nav class="Navigation navbar bg-dark navbar-expand-lg navbar-dark sticky-top py-1 py-lg-2">
    <div class="container-xxl">
      <a
        class="navbar-brand"
        :href="dashboardPath"
      >
        <img
          :src="monogramUrl"
          alt=""
          class="Navigation__logo"
          aria-hidden="true"
        >

        <span class="d-none d-lg-inline-block ms-3">
          {{ t('app_name') }}
        </span>
      </a>

      <a
        class="text-decoration-none d-block d-xxl-none"
        href="#"
        data-bs-toggle="offcanvas"
        data-bs-target="#verticalMenu"
        aria-controls="verticalMenu"
      >
        <FontAwesomeIcon
          icon="bars"
          size="lg"
          class="fs-1 text-light text-hover-light"
        />
      </a>
    </div>
  </nav>
</template>

<script>
import { onMounted, ref } from 'vue';

import I18n from '~/utils/I18n.js';
import useUserStore from '~/stores/UserStore.js';
import { dashboards as dashboardsApi } from '~/api/all.js';

import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';

export default {
  components: {
    FontAwesomeIcon,
  },

  setup() {
    const userStore = useUserStore();
    const isUserLoggedIn = userStore.isUserLoggedIn;
    const dashboardPath = dashboardsApi.show.path();
    const monogramUrl = ref('');

    onMounted(() => {
      monogramUrl.value = document.querySelector("link[rel='icon'][type='image/svg+xml']").href;
    })

    return {
      t: I18n.scopedTranslator('views'),
      isUserLoggedIn,
      dashboardPath,
      monogramUrl,
    };
  },
};
</script>

<style lang="scss" scoped>
@import '../../stylesheets/variables';

.Navigation {
  height: $main-navbar-height;
}

@include media-breakpoint-down(md) {
  .Navigation .btn {
    --bs-btn-padding-y: 0.5rem;
    --bs-btn-padding-x: 1rem;
    --bs-btn-font-size: 0.875rem;
    --bs-btn-border-radius: 0.25rem;
  }
}

.Navigation__logo {
  max-height: 3rem;
}
</style>
