<template>
  <div class="container-fluid px-0 h-100 background-curved-lines">
    <Navigation />
    <VerticalMenu />

    <div class="container-xxl px-3 pt-4">
      <FlashMessages :flash-messages="flashMessages" />

      <slot />
    </div>
  </div>
</template>

<script>
import Navigation from '~/components/layout/Navigation.vue';
import VerticalMenu from '~/components/layout/VerticalMenu.vue';
import FlashMessages from '~/components/layout/FlashMessages.vue';

import useUserStore from '~/stores/UserStore.js';
import useAccountStore from '~/stores/AccountStore.js';

export default {
  components: {
    FlashMessages,
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
    account: {
      type: Object,
      required: true,
    },
  },
  setup(props) {
    if (props.account) {
      const accountStore = useAccountStore();
      /* eslint-disable-next-line vue/no-setup-props-destructure */
      accountStore.account = props.account;
    }

    if (props.user) {
      const userStore = useUserStore();

      /* eslint-disable-next-line vue/no-setup-props-destructure */
      userStore.user = props.user;
    }
  },
};
</script>
