<template>
  <table class="table align-middle bg-white">
    <thead class="table-light">
      <tr>
        <th>{{ t('currency') }}</th>
        <th></th>
      </tr>
    </thead>
    <tbody class="table-group-divider">
      <tr
        v-for="account in accounts"
        :key="account.id"
      >
        <td>{{ account.currency_object.name }}</td>
        <td>
          <a
            :href="editAccountPath(account.id)"
            class="btn btn-outline-secondary btn-sm"
          >
            {{ t('edit') }}
          </a>

          <a
            :href="destroyAccountPath(account.id)"
            data-method="DELETE"
            :data-confirm="t('delete_confirmation')"
            class="btn btn-outline-danger btn-sm ms-2"
          >
            {{ t('delete') }}
          </a>
        </td>
      </tr>
    </tbody>
  </table>
</template>

<script>
import { accounts } from '~/api';
import I18n from '~/utils/I18n.js';

export default {
  props: {
    accounts: {
      type: Array,
      required: true,
    },
  },

  setup() {
    const editAccountPath = (accountId) => accounts.edit.path({ id: accountId });
    const destroyAccountPath = (accountId) => accounts.destroy.path({ id: accountId });

    return {
      editAccountPath,
      destroyAccountPath,
      t: I18n.scopedTranslator('views.accounts.index'),
    };
  },
};
</script>
