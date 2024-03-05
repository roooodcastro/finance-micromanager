<template>
  <tr>
    <td>
      <input
        :value="transaction.name"
        class="form-control"
        required
      >
    </td>

    <td class="width-15rem">
      <div class="input-group">
        <span class="input-group-text px-3">
          {{ currencySymbol }}
        </span>

        <input
          :value="transaction.amount"
          type="number"
          class="form-control px-3 fw-bold"
          :class="{ 'text-debit': isSpend, 'text-credit': isIncome }"
          step="0.01"
          required
        >
      </div>
    </td>

    <td class="width-10rem">
      <input
        :value="transaction.transactionDate"
        class="form-control px-3"
        type="date"
        required
      >
    </td>

    <td>
      <CategoriesSelect
        :value="transaction.categoryId"
        required
      />
    </td>

    <td />
  </tr>
</template>

<script>
import { computed } from 'vue';
import { storeToRefs } from 'pinia';

import I18n from '~/utils/I18n.js';
import useProfileStore from '~/stores/ProfileStore.js';

import CategoriesSelect from '~/components/categories/CategoriesSelect.vue';

export default {
  components: {
    CategoriesSelect,
  },

  props: {
    transaction: {
      type: Object,
      required: true,
    },
  },

  setup(props) {
    const t = I18n.scopedTranslator('views.imports.preview');

    const profileStore = useProfileStore();
    const { currentProfile } = storeToRefs(profileStore);
    const currencySymbol = computed(() => currentProfile.value.currencyObject.symbol);
    const isSpend = computed(() => props.transaction.amount < 0);
    const isIncome = computed(() => props.transaction.amount > 0);

    return {
      t,
      currencySymbol,
      isSpend,
      isIncome,
    };
  },
};
</script>
