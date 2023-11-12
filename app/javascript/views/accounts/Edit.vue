<template>
  <div>
    <PageHeader :page-title="t('edit_title', { account: account.id })" />

    <div class="row justify-content-center">
      <div class="col col-md-8 col-lg-6 col-xl-4">
        <AccountForm :account="account" />
      </div>
    </div>
  </div>
</template>

<script>
import { accounts } from '~/api';
import I18n from '~/utils/I18n';

import PageHeader from '~/components/layout/PageHeader.vue';
import AccountForm from '~/components/accounts/AccountForm.vue';

export default {
  components: {
    AccountForm,
    PageHeader,
  },

  props: {
    account: {
      type: Object,
      required: true,
    },
  },

  setup() {
    const listAccountsPath = accounts.index.path();

    return {
      listAccountsPath,
      t: I18n.scopedTranslator('views.accounts.form'),
    };
  },
};
</script>
