<template>
  <div class="container-fluid px-0">
    <Navbar />

    <div class="container-xxl px-3">

      <slot />
    </div>
  </div>
</template>

<script>
import Navbar from '@/components/layout/Navbar.vue';

export default {
  components: {
    Navbar,
  },
};
</script>
