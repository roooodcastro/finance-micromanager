<template>
  <div>
    <PageHeader :title="t('title')">
      <template v-slot:actions>
        <a
          :href="newAccountPath"
          class="btn btn-outline-secondary"
        >
          {{ t('new') }}
        </a>
      </template>
    </PageHeader>

    <AccountShareInvitesList />

    <AccountsList :accounts="accounts" />
  </div>
</template>

<script>
import { accounts } from '~/api';
import I18n from '~/utils/I18n';

import PageHeader from '~/components/layout/PageHeader.vue';
import AccountsList from '~/components/accounts/AccountsList.vue';
import AccountShareInvitesList from '~/components/account_share_invites/AccountShareInvitesList.vue';

export default {
  components: {
    AccountsList,
    PageHeader,
    AccountShareInvitesList,
  },

  props: {
    accounts: {
      type: Array,
      required: true,
    },
  },

  setup() {
    const newAccountPath = accounts.new.path();

    return {
      newAccountPath,
      t: I18n.scopedTranslator('views.accounts.index'),
    };
  },
};
</script>
