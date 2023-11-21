<template>
  <div>
    <PageHeader :title="t('title')">
      <template v-slot:actions>
        <a
          :href="newWalletPath"
          class="btn btn-outline-secondary"
        >
          {{ t('new') }}
        </a>
      </template>
    </PageHeader>

    <WalletShareInviteModal />

    <WalletShareInvitesList />

    <WalletsList :wallets="wallets" />
  </div>
</template>

<script>
import { wallets } from '~/api';
import I18n from '~/utils/I18n';

import PageHeader from '~/components/layout/PageHeader.vue';
import WalletsList from '~/components/wallets/WalletsList.vue';
import WalletShareInvitesList from '~/components/wallet_share_invites/WalletShareInvitesList.vue';
import WalletShareInviteModal from '~/components/wallet_share_invites/WalletShareInviteModal.vue';

export default {
  components: {
    WalletShareInviteModal,
    WalletShareInvitesList,
    WalletsList,
    PageHeader,
  },

  props: {
    wallets: {
      type: Array,
      required: true,
    },
  },

  setup() {
    const newWalletPath = wallets.new.path();

    return {
      newWalletPath,
      t: I18n.scopedTranslator('views.wallets.index'),
    };
  },
};
</script>
