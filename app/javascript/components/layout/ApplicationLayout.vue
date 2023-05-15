<template>
  <div class="container-fluid px-0">
    <Navigation />
    <VerticalMenu />

    <div class="container-xxl px-3 pt-4">
      <slot />
    </div>
  </div>
</template>

<script>
import Navigation from '~/components/layout/Navigation.vue';
import VerticalMenu from '~/components/layout/VerticalMenu.vue';

export default {
  components: {
    Navigation,
    VerticalMenu,
  },
};
</script>
