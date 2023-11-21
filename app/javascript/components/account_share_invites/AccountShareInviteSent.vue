<template>
  <div class="card rounded mb-3 shadow">
    <div :class="`card-body d-flex side-strip ps-4 side-strip-rounded side-strip-warning`">
      <div :class="`align-self-center text-warning`">
        <FontAwesomeIcon
          class="AccountShareInvite__icon ms-4 me-5 d-none d-lg-block"
          icon="circle-info"
        />
      </div>
      <div>
        <h5 :class="`text-warning`">
          {{ t('sent_invite_title', { invitee: accountShareInvite.inviteeEmail, account_name: accountShareInvite.account.displayName }) }}
        </h5>

        {{ t('sent_invite_text') }}
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

  setup() {
    return { t: I18n.scopedTranslator('views.account_share_invites.index') };
  },
};
</script>

<style lang="scss" scoped>
.AccountShareInvite__icon {
  font-size: 3em;
}
</style>
