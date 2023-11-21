<template>
  <nav class="Navigation navbar bg-dark navbar-expand-lg navbar-dark sticky-top py-3 py-lg-3">
    <div class="container-xxl">
      <WalletSwitcher v-if="isUserLoggedIn" />
      <span v-else></span>

      <a
        class="navbar-brand d-none d-md-inline-block"
        :href="dashboardPath"
      >
        Finance MicroManager
      </a>

      <button
        class="btn btn-sm btn-primary"
        type="button"
        data-bs-toggle="offcanvas"
        data-bs-target="#verticalMenu"
        aria-controls="verticalMenu"
      >
        <span class="navbar-toggler-icon"></span>
      </button>
    </div>
  </nav>
</template>

<script>
import useUserStore from '~/stores/UserStore.js';

import WalletSwitcher from '~/components/layout/WalletSwitcher.vue';

import { dashboards as dashboardsApi } from '~/api';

export default {
  components: {
    WalletSwitcher,
  },

  setup() {
    const userStore = useUserStore();
    const isUserLoggedIn = userStore.isUserLoggedIn;
    const dashboardPath = dashboardsApi.show.path();

    return {
      isUserLoggedIn,
      dashboardPath,
    };
  },
};
</script>

<style lang="scss" scoped>
@import '../../stylesheets/variables';

@include media-breakpoint-down(md) {
  .Navigation .btn {
    --bs-btn-padding-y: 0.5rem;
    --bs-btn-padding-x: 1rem;
    --bs-btn-font-size: 0.875rem;
    --bs-btn-border-radius: 0.25rem;
  }
}
</style>
