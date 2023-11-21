<template>
  <div class="card rounded mb-3 shadow">
    <div :class="`card-body d-flex side-strip ps-4 side-strip-rounded side-strip-${accentClass}`">
      <div :class="`align-self-center text-${accentClass}`">
        <FontAwesomeIcon
          class="WalletShareInvite__icon ms-4 me-5 d-none d-lg-block"
          :icon="faIcon"
        />
      </div>
      <div>
        <h5 :class="`text-${accentClass}`">
          {{ t(`pending_invite_title_${walletShareInvite.status}`) }}
        </h5>

        {{ pendingInviteText }}

        <div
          v-if="isPending"
          class="WalletShareInvite__button-container d-grid gap-2 gap-lg-0 d-lg-flex mt-3"
        >
          <button
            class="btn btn-sm btn-primary"
            @click="$emit('accepted')"
          >
            {{ t('accept') }}
          </button>
          <button
            class="btn btn-sm btn-danger ms-lg-3"
            @click="$emit('rejected')"
          >
            {{ t('reject') }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import I18n from '~/utils/I18n';

import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';

export default {
  components: {
    FontAwesomeIcon,
  },

  props: {
    walletShareInvite: {
      type: Object,
      required: true,
    },
  },

  emits: ['accepted', 'rejected'],

  setup(props) {
    const t = I18n.scopedTranslator('views.wallet_share_invites.index');

    const pendingInviteText = t(`pending_invite_text_${props.walletShareInvite.status}`, {
      inviter: props.walletShareInvite.walletOwner.fullName,
      wallet_name: props.walletShareInvite.wallet.displayName,
    });

    const accentClassStatusMap = {
      'pending': 'info',
      'accepted': 'primary',
      'rejected': 'danger',
    };

    const iconStatusMap = {
      'pending': 'share-nodes',
      'accepted': ['far', 'circle-check'],
      'rejected': ['far', 'circle-xmark'],
    }

    const accentClass = accentClassStatusMap[props.walletShareInvite.status];
    const faIcon = iconStatusMap[props.walletShareInvite.status];
    const isPending = props.walletShareInvite.status === 'pending';

    return {
      t,
      isPending,
      faIcon,
      accentClass,
      pendingInviteText,
    };
  },
};
</script>

<style lang="scss" scoped>
@import '../../stylesheets/variables';

.WalletShareInvite__icon {
  font-size: 3em;
}

@include media-breakpoint-down(md) {
  .WalletShareInvite__button-container {
    grid-template-columns: auto auto;
  }
}
</style>
