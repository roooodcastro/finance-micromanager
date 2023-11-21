<template>
  <div class="WalletListItem d-flex bg-light-subtle align-items-center border mx-2 mx-lg-0 bg-white p-2">
    <FontAwesomeIcon
      size="lg"
      class="WalletListItem__currency-icon text-secondary me-3"
      :icon="faIconForCurrency(wallet.currency)"
    />

    <div class="flex-grow-1">
      {{ wallet.name || t('no_name') }}
      <span class="d-block fs-6 text-muted">
        {{ wallet.currencyObject.name }}
      </span>

      <div
        v-if="wallet.shared"
        class="fs-6 text-muted"
      >
        <FontAwesomeIcon
          class=" text-primary me-2"
          icon="share-nodes"
        />
        {{ t('shared_text', { user: wallet.user.fullName }) }}
      </div>
    </div>

    <div class="text-end">
      <a
        class="text-secondary"
        href="#"
        data-bs-toggle="modal"
        data-bs-target="#walletShareInviteModal"
        @click="handleWalletShareInviteModalClick(wallet.id)"
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
        :href="editWalletPath(wallet.id)"
        class="ms-2"
      />

      <DeleteButton
        small
        disable-label
        :href="destroyWalletPath(wallet.id)"
        class="ms-2"
      />
    </div>
  </div>
</template>

<script>
import { wallets as walletsApi } from '~/api';
import I18n from '~/utils/I18n.js';
import { faIconForCurrency } from '~/utils/CurrencyIcons.js';
import useWalletStore from '~/stores/WalletStore.js';

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
    wallet: {
      type: Object,
      required: true,
    },
  },

  setup() {
    const walletStore = useWalletStore();
    const editWalletPath = (walletId) => walletsApi.edit.path({ id: walletId });
    const destroyWalletPath = (walletId) => walletsApi.destroy.path({ id: walletId });
    const handleWalletShareInviteModalClick = walletId => walletStore.setWalletIdForInviteModal(walletId);

    return {
      editWalletPath,
      destroyWalletPath,
      faIconForCurrency,
      handleWalletShareInviteModalClick,
      t: I18n.scopedTranslator('views.wallets.index'),
    };
  },
};
</script>

<style lang="scss" scoped>
.WalletListItem__currency-icon {
  width: 2em;
}

.WalletListItem:not(:first-child) {
  margin-top: -1px;
}
</style>
