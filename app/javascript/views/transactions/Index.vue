<template>
  <div>
    <PageHeader :title="t('title')">
      <template v-slot:actions>
        <DropdownMenuItem
          href="#"
          data-bs-toggle="modal"
          :data-bs-target="`#${TRANSACTION_FORM_MODAL_ID}`"
          :label="t('new')"
          icon="plus"
          @click="handleClick"
        />
      </template>
    </PageHeader>

    <TransactionsList
      :transactions="transactions"
      :pagination="pagination"
    />
  </div>
</template>

<script>
import I18n from '~/utils/I18n';
import { getQueryParams } from '~/utils/QueryStringUtils.js';
import { TRANSACTION_FORM_MODAL_ID } from '~/utils/Constants.js';

import PageHeader from '~/components/layout/PageHeader.vue';
import TransactionsList from '~/components/transactions/TransactionsList.vue';
import DropdownMenuItem from '~/components/ui/DropdownMenuItem.vue';
import useTransactionStore from '@/stores/TransactionStore';

export default {
  components: {
    PageHeader,
    DropdownMenuItem,
    TransactionsList,
  },

  props: {
    transactions: {
      type: Array,
      required: true,
    },
    pagination: {
      type: Object,
      required: true,
    },
  },

  setup() {
    const transactionStore = useTransactionStore();

    const daysToShowFromQuery = getQueryParams().daysToShow;
    if (daysToShowFromQuery) {
      transactionStore.setFetchParams({ daysToShow: daysToShowFromQuery });
    }

    transactionStore.setFetchParams({
      excludeDebits: !!getQueryParams().excludeDebits,
      excludeCredits: !!getQueryParams().excludeCredits,
    });

    const handleClick = () => transactionStore.setTransactionIdForFormModal(null);

    return {
      t: I18n.scopedTranslator('views.transactions.index'),
      handleClick,
      TRANSACTION_FORM_MODAL_ID,
    };
  },
};
</script>
