<template>
  <div class="GridRow__left">
    <div class="d-flex gap-2 align-items-center">
      <span>{{ profile.name || t('no_name') }}</span>

      <DisabledBadge v-if="isDisabled" />
    </div>
    <div>{{ profile.currencyObject.name }} ({{ profile.currencyObject.symbol }})</div>
  </div>

  <div class="GridRow__right">
    <div>{{ profile.defaultWallet?.name ?? t('no_default_wallet') }}</div>

    <div>
      <FontAwesomeIcon
        v-if="profile.shared"
        class="text-primary me-2"
        icon="share-nodes"
      />
      {{ profile.user.displayName }}
    </div>
  </div>
</template>

<script>
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';
import { computed } from 'vue';

import I18n from '~/utils/I18n.js';

import DisabledBadge from '~/components/bootstrap/DisabledBadge.vue';

export default {
  components: {
    DisabledBadge,
    FontAwesomeIcon,
  },

  props: {
    profile: {
      type: Object,
      required: true,
    },
  },

  setup(props) {
    const isDisabled = computed(() => props.profile.status === 'disabled');
    return {
      t: I18n.scopedTranslator('views.components.profiles_list'),
      isDisabled,
    };
  },
};
</script>
