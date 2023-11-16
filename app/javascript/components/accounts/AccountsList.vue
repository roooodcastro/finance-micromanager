<template>
  <div class="AccountsList">
    <AccountListItem
      v-for="account in accounts"
      :key="account.id"
      :account="account"
    />
  </div>
</template>

<script>
import I18n from '~/utils/I18n.js';

import AccountListItem from '~/components/accounts/AccountListItem.vue';

export default {
  components: {
    AccountListItem,
  },

  props: {
    accounts: {
      type: Array,
      required: true,
    },
  },

  setup() {
    return {
      t: I18n.scopedTranslator('views.accounts.index'),
    };
  },
};
</script>

<style lang="scss" scoped>
@import '../../stylesheets/variables';

@include media-breakpoint-down(md) {
  .AccountsList {
    margin-left: -1rem;
    margin-right: -1rem;
    width: calc(100% + 2rem);
  }
}
</style>
