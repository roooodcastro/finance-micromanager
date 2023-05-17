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

import useUserStore from '~/stores/UserStore.js';

export default {
  components: {
    Navigation,
    VerticalMenu,
  },
  props: {
    user: {
      type: Object,
      required: true,
    },
  },
  setup(props) {
    if (props.user) {
      const userStore = useUserStore();

      /* eslint-disable-next-line vue/no-setup-props-destructure */
      userStore.user = props.user;
    }
  },
};
</script>
