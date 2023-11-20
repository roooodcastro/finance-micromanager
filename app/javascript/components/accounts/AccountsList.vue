<template>
  <div class="AccountsList">
    <AccountListItem
      v-for="account in accountsFromStore"
      :key="account.id"
      :account="account"
    />
  </div>
</template>

<script>
import { storeToRefs } from 'pinia';

import I18n from '~/utils/I18n.js';
import useAccountStore from '~/stores/AccountStore';

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

  setup(props) {
    const accountStore = useAccountStore();

    const { availableAccounts: accountsFromStore } = storeToRefs(accountStore);
    accountsFromStore.value = props.accounts;

    return {
      t: I18n.scopedTranslator('views.accounts.index'),
      accountsFromStore,
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
