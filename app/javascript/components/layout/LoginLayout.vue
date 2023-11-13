<template>
  <div class="container-fluid pt-3 h-100 bg-primary background-curved-lines LoginLayout">
    <div class="row justify-content-center mt-5">
      <div class="col col-lg-6 col-xl-4">
        <h1 class="mb-5">
          <a
            :href="landingPath"
            class="text-reset text-decoration-none link-light"
          >
            Finance MicroManager
          </a>
        </h1>

        <FlashMessages :flash-messages="flashMessages" />

        <slot />
      </div>
    </div>
  </div>
</template>

<script>
import { landings } from '~/api';

import FlashMessages from '~/components/layout/FlashMessages.vue';

import useFlashStore from "~/stores/FlashStore";

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

  setup(props) {
    const landingPath = landings.show.path();

    if (props.flashMessages) {
      useFlashStore().setMessages(props.flashMessages);
    }

    return { landingPath };
  }
};
</script>

<style lang="scss" scoped>
@import '../../stylesheets/variables';

.LoginLayout h1 {
  color: $mintgreen-100;
  text-align: center;
}
</style>
