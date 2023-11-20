<template>
  <div class="AccountListItem d-flex bg-light-subtle align-items-center border mx-2 mx-lg-0 bg-white p-2">
    <FontAwesomeIcon
      size="lg"
      class="AccountListItem__currency-icon text-secondary me-3"
      :icon="faIconForCurrency(account.currency)"
    />

    <div class="flex-grow-1">
      {{ account.name || t('no_name') }}
      <span class="d-block fs-6 text-muted">
        {{ account.currencyObject.name }}
      </span>

      <div
        v-if="account.shared"
        class="fs-6 text-muted"
      >
        <FontAwesomeIcon
          class=" text-primary me-2"
          icon="share-nodes"
        />
        {{ t('shared_text', { user: account.user.fullName }) }}
      </div>
    </div>

    <div class="text-end">
      <a
        class="text-secondary"
        href="#"
        data-bs-toggle="modal"
        data-bs-target="#accountShareInviteModal"
        @click="handleAccountShareInviteModalClick(account.id)"
      >
        <FontAwesomeIcon
          icon="share-nodes"
          size="lg"
        />
        <span class="d-none d-lg-inline-block ms-2">
          {{ t('share_action_link_label') }}
        </span>
      </a>

      <EditButton
        small
        :href="editAccountPath(account.id)"
        class="ms-2"
      />

      <DeleteButton
        small
        disable-label
        :href="destroyAccountPath(account.id)"
        class="ms-2"
      />
    </div>
  </div>
</template>

<script>
import { accounts as accountsApi } from '~/api';
import I18n from '~/utils/I18n.js';
import { faIconForCurrency } from '~/utils/CurrencyIcons.js';
import useAccountStore from '~/stores/AccountStore.js';

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
    const accountStore = useAccountStore();
    const editAccountPath = (accountId) => accountsApi.edit.path({ id: accountId });
    const destroyAccountPath = (accountId) => accountsApi.destroy.path({ id: accountId });
    const handleAccountShareInviteModalClick = accountId => accountStore.setAccountIdForInviteModal(accountId);

    return {
      editAccountPath,
      destroyAccountPath,
      faIconForCurrency,
      handleAccountShareInviteModalClick,
      t: I18n.scopedTranslator('views.accounts.index'),
    };
  },
};
</script>

<style lang="scss" scoped>
.AccountListItem__currency-icon {
  width: 2em;
}

.AccountListItem:not(:first-child) {
  margin-top: -1px;
}
</style>
