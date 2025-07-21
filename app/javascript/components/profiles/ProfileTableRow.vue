<template>
  <div class="GridRow__left">
    <div class="d-flex gap-2 align-items-center">
      <span>{{ profile.name || t('no_name') }}</span>

      <Badge
        v-if="isDisabled"
        type="disabled"
      />
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

import Badge from '~/components/ui/Badge.vue';

export default {
  components: {
    Badge,
    FontAwesomeIcon,
  },

  props: {
    profile: {
      type: Object,
      required: true,
    },
  },

  setup(props) {
    const isDisabled = computed(() => !!props.profile.disabledAt);
    return {
      t: I18n.scopedTranslator('views.components.profiles_list'),
      isDisabled,
    };
  },
};
</script>
