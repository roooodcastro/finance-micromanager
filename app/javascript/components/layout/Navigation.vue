<template>
  <nav
    class="Navigation navbar navbar-expand-lg py-1 py-lg-2"
    data-bs-theme="dark"
  >
    <div class="container-fluid">
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

        <span class="d-none d-md-inline-block ms-3">
          {{ t('app_name') }}
        </span>
      </a>

      <div
        v-if="isUserLoggedIn"
        class="flex-grow-1 d-flex justify-content-end pe-3"
      >
        <DateRangeSelector
          v-if="showDateRangePicker"
          id="Navigation__DateRangeSelector"
          class="d-lg-none"
        />
      </div>

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
          class="fs-1 link-light"
        />
      </a>
    </div>
  </nav>
</template>

<script>
import { onMounted, ref } from 'vue';
import { storeToRefs } from 'pinia';

import I18n from '~/utils/I18n.js';
import useUserStore from '~/stores/UserStore.js';
import useDateRangeStore from '~/stores/DateRangeStore.js';
import { dashboards as dashboardsApi } from '~/api/all.js';

import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';

import DateRangeSelector from '~/components/layout/DateRangeSelector.vue';

export default {
  components: {
    DateRangeSelector,
    FontAwesomeIcon,
  },

  setup() {
    const userStore = useUserStore();
    const isUserLoggedIn = userStore.isUserLoggedIn;
    const dashboardPath = dashboardsApi.show.path();
    const monogramUrl = ref('');

    const dateRangeStore = useDateRangeStore();
    const { showDateRangePicker } = storeToRefs(dateRangeStore);

    onMounted(() => {
      monogramUrl.value = document.querySelector("link[rel='icon'][type='image/svg+xml']").href;
    })

    return {
      t: I18n.scopedTranslator('views'),
      isUserLoggedIn,
      dashboardPath,
      monogramUrl,
      showDateRangePicker,
    };
  },
};
</script>

<style lang="scss" scoped>
@import '../../stylesheets/variables';

.Navigation {
  background-color: $mintgreen-900;
  height: $main-navbar-height;
  position: sticky;
  top: 0;
  z-index: 1020;
}

@include media-breakpoint-down(md) {
  .Navigation {
    position: initial;
    top: initial;
    z-index: initial;
  }

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
