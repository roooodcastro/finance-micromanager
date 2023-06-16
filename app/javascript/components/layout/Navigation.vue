<template>
  <nav class="navbar bg-dark navbar-expand-lg navbar-dark" data-bs-theme="dark">
    <div class="container-xxl">
      <AccountSwitcherButton />

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
import AccountSwitcherButton from '~/components/layout/AccountSwitcherButton.vue';

export default {
  components: {
    AccountSwitcherButton,
  },
};
</script>
