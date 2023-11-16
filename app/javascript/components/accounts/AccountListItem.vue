<template>
  <div class="AccountListItem d-flex bg-light-subtle align-items-center border mx-2 mx-lg-0 bg-white p-2">
    <FontAwesomeIcon
      size="lg"
      class="text-secondary me-3"
      :icon="faIconForCurrency(account.currency)"
    />

    <div class="flex-grow-1">
      {{ account.name || t('no_name') }}
      <span class="d-block fs-6 text-muted">
        {{ account.currencyObject.name }}
      </span>
    </div>

    <td class="text-end">
      <EditButton
        small
        :href="editAccountPath(account.id)"
      />

      <DeleteButton
        small
        disable-label
        :href="destroyAccountPath(account.id)"
        class="ms-2"
      />
    </td>
  </div>
</template>

<script>
import { accounts as accountsApi } from '~/api';
import I18n from '~/utils/I18n.js';
import { faIconForCurrency } from '~/utils/CurrencyIcons.js';

import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';

import EditButton from '~/components/rails/EditButton.vue';
import DeleteButton from '~/components/rails/DeleteButton.vue';

export default {
  components: {
    DeleteButton,
    EditButton,
    FontAwesomeIcon,
  },

  props: {
    account: {
      type: Object,
      required: true,
    },
  },

  setup() {
    const editAccountPath = (accountId) => accountsApi.edit.path({ id: accountId });
    const destroyAccountPath = (accountId) => accountsApi.destroy.path({ id: accountId });

    return {
      editAccountPath,
      destroyAccountPath,
      faIconForCurrency,
      t: I18n.scopedTranslator('views.accounts.index'),
    };
  },
};
</script>

<style lang="scss" scoped>
.AccountListItem:not(:first-child) {
  margin-top: -1px;
}
</style>
