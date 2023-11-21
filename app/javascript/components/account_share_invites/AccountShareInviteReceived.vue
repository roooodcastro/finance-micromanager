<template>
  <div class="card rounded mb-3 shadow">
    <div :class="`card-body d-flex side-strip ps-4 side-strip-rounded side-strip-${accentClass}`">
      <div :class="`align-self-center text-${accentClass}`">
        <FontAwesomeIcon
          class="AccountShareInvite__icon ms-4 me-5 d-none d-lg-block"
          :icon="faIcon"
        />
      </div>
      <div>
        <h5 :class="`text-${accentClass}`">
          {{ t(`pending_invite_title_${accountShareInvite.status}`) }}
        </h5>

        {{ pendingInviteText }}

        <div
          v-if="isPending"
          class="AccountShareInvite__button-container d-grid gap-2 gap-lg-0 d-lg-flex mt-3"
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
    accountShareInvite: {
      type: Object,
      required: true,
    },
  },

  emits: ['accepted', 'rejected'],

  setup(props) {
    const t = I18n.scopedTranslator('views.account_share_invites.index');

    const pendingInviteText = t(`pending_invite_text_${props.accountShareInvite.status}`, {
      inviter: props.accountShareInvite.accountOwner.fullName,
      account_name: props.accountShareInvite.account.displayName,
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

    const accentClass = accentClassStatusMap[props.accountShareInvite.status];
    const faIcon = iconStatusMap[props.accountShareInvite.status];
    const isPending = props.accountShareInvite.status === 'pending';

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

.AccountShareInvite__icon {
  font-size: 3em;
}

@include media-breakpoint-down(md) {
  .AccountShareInvite__button-container {
    grid-template-columns: auto auto;
  }
}
</style>
