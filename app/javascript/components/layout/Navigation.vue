<template>
  <nav class="navbar bg-dark navbar-expand-lg navbar-dark" data-bs-theme="dark">
    <div class="container-xxl">
      <AccountSwitcher v-if="isUserLoggedIn" />
      <span v-else></span>

      <a class="navbar-brand d-none d-md-inline-block" href="#">Finance MicroManager</a>

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

export default {
  components: {
    AccountSwitcher,
  },

  setup() {
    const userStore = useUserStore();
    const isUserLoggedIn = userStore.isUserLoggedIn;

    return { isUserLoggedIn };
  },
};
</script>
