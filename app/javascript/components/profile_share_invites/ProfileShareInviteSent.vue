<template>
  <div class="card rounded mb-3 shadow">
    <div :class="`card-body d-flex flex-column flex-lg-row justify-content-between side-strip ps-4 side-strip-rounded side-strip-${accentClass}`">
      <div class="d-flex">
        <div :class="`align-self-center text-${accentClass}`">
          <FontAwesomeIcon
            class="ProfileShareInvite__icon ms-4 me-5 d-none d-lg-block"
            :icon="faIcon"
          />
        </div>
        <div>
          <h5 :class="`text-${accentClass}`">
            {{ t('sent_invite_title', { invitee: profileShareInvite.inviteeEmail, profile_name: profileShareInvite.profile.displayName }) }}
          </h5>

          {{ t(`sent_invite_text_${profileShareInvite.status}`) }}
        </div>
      </div>
      <div
        v-if="isPending"
        class="align-self-lg-center"
      >
        <button
          class="btn btn-danger btn-sm mt-3 mt-lg-0"
          @click="$emit('cancelled')"
        >
          {{ t('cancel') }}
        </button>
      </div>
    </div>
  </div>
</template>

<script>
import I18n from '~/utils/I18n.js';

import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';

export default {
  components: {
    FontAwesomeIcon,
  },

  props: {
    profileShareInvite: {
      type: Object,
      required: true,
    },
  },

  emits: ['cancelled'],

  setup(props) {
    const t = I18n.scopedTranslator('views.profile_share_invites.index');

    const accentClassStatusMap = {
      'pending': 'warning',
      'cancelled': 'danger',
    };

    const iconStatusMap = {
      'pending': 'circle-info',
      'cancelled': ['far', 'circle-xmark'],
    }

    const accentClass = accentClassStatusMap[props.profileShareInvite.status];
    const faIcon = iconStatusMap[props.profileShareInvite.status];
    const isPending = props.profileShareInvite.status === 'pending';

    return {
      t,
      isPending,
      faIcon,
      accentClass,
    };
  },
};
</script>

<style lang="scss" scoped>
.ProfileShareInvite__icon {
  font-size: 3em;
}
</style>
