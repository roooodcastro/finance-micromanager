<template>
  <div class="d-flex flex-column container-fluid px-0 h-100 background-curved-lines">
    <Navigation />
    <VerticalMenu />

    <div
      class="my-3 flex-shrink-0"
      :class="{ 'container-xxl': !skipContainer, 'px-3': !skipContainer }"
    >
      <FlashMessages :flash-messages="flashMessages" />

      <slot />
    </div>

    <PageFooter />
  </div>
</template>

<script>
import FlashMessages from '~/components/layout/FlashMessages.vue';
import Navigation from '~/components/layout/Navigation.vue';
import PageFooter from '~/components/layout/PageFooter.vue';
import VerticalMenu from '~/components/layout/VerticalMenu.vue';

import useUserStore from '~/stores/UserStore.js';
import useFlashStore from '~/stores/FlashStore.js';
import useAccountStore from '~/stores/AccountStore.js';

export default {
  components: {
    FlashMessages,
    PageFooter,
    Navigation,
    VerticalMenu,
  },
  props: {
    flashMessages: {
      type: Object,
      required: true,
    },
    user: {
      type: Object,
      required: true,
    },
    currentAccount: {
      type: Object,
      required: true,
    },
    availableAccounts: {
      type: Object,
      required: true,
    },
    skipContainer: {
      type: Boolean,
      default: false,
    },
  },
  setup(props) {
    const accountStore = useAccountStore();

    if (props.currentAccount) {
      /* eslint-disable-next-line vue/no-setup-props-destructure */
      accountStore.currentAccount = props.currentAccount;
    }

    if (props.availableAccounts) {
      /* eslint-disable-next-line vue/no-setup-props-destructure */
      accountStore.availableAccounts = props.availableAccounts;
    }

    if (props.user) {
      const userStore = useUserStore();

      /* eslint-disable-next-line vue/no-setup-props-destructure */
      userStore.user = props.user;
    }

    if (props.flashMessages) {
      useFlashStore().setMessages(props.flashMessages);
    }
  },
};
</script>
