<template>
  <nav class="Navigation navbar bg-dark navbar-expand-lg navbar-dark sticky-top py-2 py-lg-3">
    <div class="container-xxl">
      <a
        class="navbar-brand"
        :href="dashboardPath"
      >
        Finance MicroManager
      </a>

      <a
        class="text-decoration-none"
        href="#"
        data-bs-toggle="offcanvas"
        data-bs-target="#verticalMenu"
        aria-controls="verticalMenu"
      >
        <ProfileAvatar />
      </a>
    </div>
  </nav>
</template>

<script>
import useUserStore from '~/stores/UserStore.js';
import { dashboards as dashboardsApi } from '~/api';

import ProfileAvatar from '~/components/layout/ProfileAvatar.vue';

export default {
  components: {
    ProfileAvatar,
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
