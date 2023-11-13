<template>
  <nav class="Navigation navbar bg-dark navbar-expand-lg navbar-dark" data-bs-theme="dark">
    <div class="container-xxl">
      <AccountSwitcher v-if="isUserLoggedIn" />
      <span v-else></span>

      <a
        class="navbar-brand d-none d-md-inline-block"
        :href="dashboardPath"
      >
        Finance MicroManager
      </a>

      <button
        class="btn btn-primary"
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

import AccountSwitcher from '~/components/layout/AccountSwitcher.vue';

import { dashboards as dashboardsApi } from '~/api';

export default {
  components: {
    AccountSwitcher,
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

<style lang="scss">
@import '../../stylesheets/variables';

@include media-breakpoint-down(md) {
  .Navigation {
    padding: 0.75rem 0;
  }
  .Navigation .btn {
    --bs-btn-padding-y: 0.5rem;
    --bs-btn-padding-x: 1rem;
    --bs-btn-font-size: 0.875rem;
    --bs-btn-border-radius: 0.25rem;
  }
}
</style>
