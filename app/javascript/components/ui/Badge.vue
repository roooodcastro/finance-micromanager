<template>
  <span :class="`badge border border-${badgeVariant} text-${badgeVariant}`">
    <FontAwesomeIcon
      v-if="!!badgeIcon"
      :icon="badgeIcon"
    />

    {{ label }}
  </span>
</template>

<script>
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';

import I18n from '~/utils/I18n.js';

const BADGE_TYPES = {
  disabled: { icon: 'ban', label: 'views.components.badges.disabled', variant: 'danger' },
  favourite: { icon: 'star', label: 'views.components.badges.favourite', variant: 'warning' },
  system: { icon: '', label: 'views.components.badges.system', variant: 'secondary' },
  income: { icon: '', label: 'views.components.badges.income', variant: 'primary' },
};

export default {
  components: { FontAwesomeIcon },

  props: {
    type: {
      type: String,
      default: null,
    },
    i18nScope: {
      type: String,
      default: '',
    },
    variant: {
      type: String,
      default: null,
    },
    icon: {
      type: [String, Array],
      default: null,
    },
  },

  setup(props) {
    const badgeIcon = props.icon ?? BADGE_TYPES[props.type]?.icon ?? '';
    const badgeVariant = props.variant ?? BADGE_TYPES[props.type]?.variant ?? 'primary';
    const label = I18n.t(props.i18nScope, { defaults: { scope: BADGE_TYPES[props.type]?.label ?? '' } });

    return {
      badgeIcon,
      label,
      badgeVariant,
    };
  },
};
</script>
