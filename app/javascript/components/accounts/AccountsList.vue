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
        <td>{{ account.currencyObject.name }}</td>

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
      </tr>
    </tbody>
  </table>
</template>

<script>
import { accounts } from '~/api';
import I18n from '~/utils/I18n.js';

import EditButton from '~/components/rails/EditButton.vue';
import DeleteButton from '~/components/rails/DeleteButton.vue';

export default {
  components: {
    DeleteButton,
    EditButton,
  },

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
