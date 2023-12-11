<template>
  <div class="toast-container position-absolute top-0 end-0 p-3">
    <Toast
      v-for="(notification, index) in notifications"
      :key="`${notification.variant}_${index}`"
      :variant="notification.variant"
      :message="notification.message"
    />
  </div>
</template>

<script>
import { storeToRefs } from 'pinia';
import useNotificationStore from '~/stores/NotificationStore.js';

import Toast from '~/components/bootstrap/Toast.vue';
import I18n from '~/utils/I18n.js';

export default {
  components: {
    Toast,
  },

  setup() {
    const t = I18n.scopedTranslator('views.layout.rails');
    const { notifications } = storeToRefs(useNotificationStore());

    return {
      t,
      notifications,
    };
  }
};
</script>
