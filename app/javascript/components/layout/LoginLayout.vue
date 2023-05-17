<template>
  <div class="container-fluid pt-5 LoginLayout">
    <div class="row justify-content-center mt-5">
      <div class="col col-lg-6 col-xl-4">
        <h1 class="mb-5">
          Finance MicroManager
        </h1>

        <FlashMessages :flash-messages="flashMessages" />

        <slot />
      </div>
    </div>
  </div>
</template>

<script>
import FlashMessages from '~/components/layout/FlashMessages.vue';

export default {
  components: {
    FlashMessages,
  },
  props: {
    flashMessages: {
      type: Object,
      required: true,
    },
  },
};
</script>

<style lang="scss" scoped>
@import '../../stylesheets/variables';

.LoginLayout {
  background-color: $primary;
  height: 100%;
}

.LoginLayout h1 {
  color: $mintgreen-100;
  text-align: center;
}
</style>
