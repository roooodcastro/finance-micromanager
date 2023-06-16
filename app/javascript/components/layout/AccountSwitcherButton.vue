<template>
  <button
    class="btn btn-primary"
    type="button"
    data-bs-toggle="popover"
    data-bs-target="#accountSwitcher"
    aria-controls="accountSwitcher"
  >
    {{ account?.currency_object?.symbol }} -
    {{ account?.currency_object?.name }}
    <FontAwesomeIcon
      class="ms-3"
      icon="chevron-down"
    />
  </button>
</template>

<script>
import useAccountStore from '~/stores/AccountStore.js';
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';

export default {
  components: {
    FontAwesomeIcon,
  },

  setup() {
    const accountStore = useAccountStore();
    const account = accountStore.account;

    return {
      account,
    };
  },
};
</script>
