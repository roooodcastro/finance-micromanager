<template>
  <div>
    <FontAwesomeIcon
      class="me-2"
      :icon="faIconForCurrency(account.currency)"
    />
    {{ account.displayName }}
  </div>
</template>

<script>
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';

import { faIconForCurrency } from "~/utils/CurrencyIcons.js";

export default {
  components: { FontAwesomeIcon },

  props: {
    account: {
      type: Object,
      required: true,
    },
  },

  setup() {
    return {
      faIconForCurrency,
    };
  },
};
</script>
