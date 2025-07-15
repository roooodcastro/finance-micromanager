<template>
  <component
    :is="noCard ? 'div' : 'BCard'"
    no-body
  >
    <template v-slot:header>
      <h4 class="m-0">
        {{ t('sub_header_recent_transactions') }}
      </h4>
    </template>

    <TransactionsList
      compact
      card-body
    />
  </component>
</template>

<script>
import I18n from '~/utils/I18n.js';

import BCard from '~/components/bootstrap/BCard.vue';
import TransactionsList from '~/components/transactions/TransactionsList.vue';

export default {
  components: {
    BCard,
    TransactionsList,
  },

  props: {
    noCard: {
      type: Boolean,
      default: false,
    },
  },

  setup() {
    return { t: I18n.scopedTranslator('views.categories.show') };
  },
};
</script>
