<template>
  <div>
    <FontAwesomeIcon
      class="me-2"
      :icon="faIconForCurrency(wallet.currency)"
    />
    {{ wallet.displayName }}
  </div>
</template>

<script>
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';

import { faIconForCurrency } from "~/utils/CurrencyIcons.js";

export default {
  components: { FontAwesomeIcon },

  props: {
    wallet: {
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
