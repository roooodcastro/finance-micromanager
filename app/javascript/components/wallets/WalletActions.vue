<template>
  <div class="vr mx-3 d-none d-lg-flex"></div>

  <a
      :class="{
        'd-flex align-items-center justify-content-center bg-info text-white': drawerMenu,
        'text-info': !drawerMenu,
      }"
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
      :class="{
        'd-flex align-items-center justify-content-center bg-secondary text-white': drawerMenu,
        'ms-3': !drawerMenu,
      }"
  />

  <DeleteButton
      small
      disable-label
      href="#"
      :class="{
        'd-flex align-items-center justify-content-center bg-danger text-white': drawerMenu,
        'ms-3': !drawerMenu,
      }"
      @delete="handleDelete(wallet.id)"
  />
</template>

<script>
import { wallets as walletsApi } from '~/api';
import I18n from '~/utils/I18n.js';
import useWalletStore from '~/stores/WalletStore.js';
import useNotificationStore from '~/stores/NotificationStore.js';

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
    drawerMenu: {
      type: Boolean,
      default: false,
    },
  },

  setup() {
    const walletStore = useWalletStore();
    const notificationStore = useNotificationStore();

    const editWalletPath = (walletId) => walletsApi.edit.path({ id: walletId });

    const handleWalletShareInviteModalClick = walletId => walletStore.setWalletIdForInviteModal(walletId);

    const handleDelete = (id) => {
      walletsApi.destroy({ id }).then((response) => {
        notificationStore.notify(response.message, 'success');
        walletStore.remove(response.walletId);
      });
    };

    return {
      editWalletPath,
      handleDelete,
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
