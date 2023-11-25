<template>
  <div class="ApplicationLayout d-flex flex-column container-fluid px-0 background-curved-lines">
    <Navigation />
    <VerticalMenu />
    <ConfirmationModal />

    <div
      class="my-3 flex-shrink-0 flex-grow-1 d-flex flex-column"
      :class="{ 'container-xxl': !skipContainer, 'px-3': !skipContainer }"
    >
      <ToastNotifications />

      <slot />

      <FloatingActionButton v-if="!skipFloatingActionButton" />
    </div>

    <PageFooter />
  </div>
</template>

<script>
import ToastNotifications from '~/components/layout/ToastNotifications.vue';
import Navigation from '~/components/layout/Navigation.vue';
import PageFooter from '~/components/layout/PageFooter.vue';
import VerticalMenu from '~/components/layout/VerticalMenu.vue';

import useUserStore from '~/stores/UserStore.js';
import useNotificationStore from '~/stores/NotificationStore.js';
import useWalletStore from '~/stores/WalletStore.js';
import FloatingActionButton from '~/components/layout/FloatingActionButton.vue';
import ConfirmationModal from '~/components/bootstrap/ConfirmationModal.vue';

export default {
  components: {
    ConfirmationModal,
    ToastNotifications,
    FloatingActionButton,
    PageFooter,
    Navigation,
    VerticalMenu,
  },
  props: {
    notifications: {
      type: Object,
      required: true,
    },
    user: {
      type: Object,
      required: true,
    },
    currentWallet: {
      type: Object,
      required: true,
    },
    availableWallets: {
      type: Object,
      required: true,
    },
    skipContainer: {
      type: Boolean,
      default: false,
    },
    skipFloatingActionButton: {
      type: Boolean,
      default: false,
    },
  },
  setup(props) {
    const walletStore = useWalletStore();

    if (props.currentWallet) {
      /* eslint-disable-next-line vue/no-setup-props-destructure */
      walletStore.currentWallet = props.currentWallet;
    }

    if (props.availableWallets) {
      /* eslint-disable-next-line vue/no-setup-props-destructure */
      walletStore.availableWallets = props.availableWallets;
    }

    if (props.user) {
      const userStore = useUserStore();

      /* eslint-disable-next-line vue/no-setup-props-destructure */
      userStore.user = props.user;
    }

    if (props.notifications) {
      useNotificationStore().loadFromProps(props.notifications);
    }
  },
};
</script>

<style lang="scss" scoped>
.ApplicationLayout {
  min-height: 100%;
}
</style>
