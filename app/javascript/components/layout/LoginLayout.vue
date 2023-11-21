<template>
  <div class="LoginLayout container-fluid pt-3 bg-primary background-curved-lines LoginLayout">
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

        <ToastNotifications />

        <slot />
      </div>
    </div>
  </div>
</template>

<script>
import { landings } from '~/api';

import ToastNotifications from '~/components/layout/ToastNotifications.vue';

import useNotificationStore from "~/stores/NotificationStore";

export default {
  components: {
    ToastNotifications,
  },

  props: {
    notifications: {
      type: Object,
      required: true,
    },
  },

  setup(props) {
    const landingPath = landings.show.path();

    if (props.notifications) {
      useNotificationStore().loadFromProps(props.notifications);
    }

    return { landingPath };
  }
};
</script>

<style lang="scss" scoped>
@import '../../stylesheets/variables';

.LoginLayout {
  min-height: 100%;
}

.LoginLayout h1 {
  color: $mintgreen-100;
  text-align: center;
}
</style>
