<template>
  <PageHeader
    :title="transactionFromStore.name"
    :sub-title="t('title')"
    :back-button-href="transactionsPath"
  >
    <template v-slot:actions>
      <DropdownMenuItem
        :label="t('edit')"
        icon="pen-to-square"
        @click="handleEdit"
      />

      <DropdownMenuItem
        :label="t('delete')"
        :icon="['far', 'trash-can']"
        class="text-bg-danger"
        @click="handleDelete"
      />
    </template>
  </PageHeader>

  <div class="row">
    <div class="col-12">
      <BCard :title="t('sub_header_summary')">
        <dl class="row">
          <dt class="col-6 col-md-4 my-1">
            {{ t('name_label') }}
          </dt>
          <dd class="col-6 col-md-8 my-1">
            {{ transactionFromStore.name }}
          </dd>
          <dt class="col-6 col-md-4 my-1">
            {{ t('amount_label') }}
          </dt>
          <dd
            class="col-6 col-md-8 my-1 fw-bold"
            :class="{ 'text-credit': isCredit, 'text-debit': isDebit }"
          >
            {{ formatMoney(transactionFromStore.amount) }}
          </dd>
          <dt class="col-6 col-md-4 my-1">
            {{ t('date_label') }}
          </dt>
          <dd class="col-6 col-md-8 my-1">
            {{ formatDate(transactionFromStore.transactionDate) }}
          </dd>
          <dt class="col-6 col-md-4 my-1">
            {{ t('category_label') }}
          </dt>
          <dd class="col-6 col-md-8 my-1">
            <a :href="categoryPath(transactionFromStore.categoryId)">
              <CategoryBadge
                :category="transactionFromStore.category"
                :subcategory="transactionFromStore.subcategory"
              />
            </a>
          </dd>
          <dt class="col-6 col-md-4 my-1">
            {{ t('wallet_label') }}
          </dt>
          <dd class="col-6 col-md-8 my-1">
            <template v-if="transactionFromStore.wallet">
              {{ transactionFromStore.wallet.name }}
            </template>
            <template v-else>
              {{ t('no_wallet') }}
            </template>
          </dd>
          <template v-if="!!transactionFromStore.transactionAutomationId">
            <dd class="col-6 col-md-4 my-1">
              {{ t('transaction_automation_label') }}
            </dd>
            <dt class="col-6 col-md-8 my-1">
              <a :href="transactionAutomationPath(transactionFromStore.transactionAutomationId)">
                <TransactionFromAutomationIndicator v-if="!!transaction.transactionAutomationId" />
                {{ t('transaction_automation_value') }}
              </a>
            </dt>
          </template>
          <template v-if="!!transactionFromStore.importId">
            <dd class="col-6 col-md-4 my-1">
              {{ t('import_label') }}
            </dd>
            <dt class="col-6 col-md-8 my-1">
              <a :href="importPath(transactionFromStore.importId)">
                {{ t('import_value') }}
              </a>
            </dt>
          </template>
        </dl>

        <hr class="my-3">

        <dl class="row">
          <dt class="col-6 col-md-4 my-1">
            {{ t('created_at_label') }}
          </dt>
          <dd class="col-6 col-md-8 my-1">
            {{ formatDateTime(transactionFromStore.createdAt) }}
          </dd>
          <dt class="col-6 col-md-4 my-1">
            {{ t('created_by_label') }}
          </dt>
          <dd class="col-6 col-md-8 my-1">
            {{ transactionFromStore.createdBy?.displayName }}
          </dd>
          <template v-if="transactionFromStore.createdAt != transactionFromStore.updatedAt">
            <dt class="col-6 col-md-4 my-1">
              {{ t('updated_at_label') }}
            </dt>
            <dd class="col-6 col-md-8 my-1">
              {{ formatDateTime(transactionFromStore.updatedAt) }}
            </dd>
            <dt class="col-6 col-md-4 my-1">
              {{ t('updated_by_label') }}
            </dt>
            <dd class="col-6 col-md-8 my-1">
              {{ transactionFromStore.updatedBy?.displayName }}
            </dd>
          </template>
        </dl>
      </BCard>
    </div>

    <div class="col-12 col-xl-6 mt-3 mt-xl-0" />
  </div>
</template>

<script>
import { computed } from 'vue';
import { storeToRefs } from 'pinia';

import I18n from '~/utils/I18n.js';
import {
  categories as categoriesApi,
  imports as importsApi,
  transactions as transactionsApi,
  transactionAutomations as transactionAutomationsApi,
} from '~/api/all.js';
import { formatMoney } from '~/utils/NumberFormatter.js';
import { formatDate, formatDateTime } from '~/utils/DateUtils.js';
import useTransactionStore from '~/stores/TransactionStore.js';

import PageHeader from '~/components/layout/PageHeader.vue';
import DropdownMenuItem from '~/components/ui/DropdownMenuItem.vue';
import BCard from '~/components/bootstrap/BCard.vue';
import TransactionFromAutomationIndicator from '~/components/transactions/TransactionFromAutomationIndicator.vue';
import CategoryBadge from '~/components/categories/CategoryBadge.vue';

export default {
  components: {
    BCard,
    CategoryBadge,
    DropdownMenuItem,
    PageHeader,
    TransactionFromAutomationIndicator,
  },

  props: {
    transaction: {
      type: Object,
      required: true,
    },
  },

  setup(props) {
    const t = I18n.scopedTranslator('views.transactions.show');

    const transactionsPath = transactionsApi.index.path();
    const categoryPath = id => categoriesApi.show.path({ id });
    const importPath = id => importsApi.show.path({ id });
    const transactionAutomationPath = id => transactionAutomationsApi.show.path({ id });

    const transactionStore = useTransactionStore();
    transactionStore.setActionName('show');

    const { transaction: transactionFromStore, transactions } = storeToRefs(transactionStore);
    transactionFromStore.value = props.transaction;
    transactions.value = [props.transaction];

    const isDebit = computed(() => transactionFromStore.value.amount < 0);
    const isCredit = computed(() => transactionFromStore.value.amount > 0);

    const handleEdit = () => transactionStore.openFormModal(props.transaction.id);
    const handleDelete = () => {
      transactionStore.destroy(props.transaction.id).then(() => {
        window.location.href = transactionsPath;
      });
    };

    return {
      t,
      transactionFromStore,
      transactionsPath,
      isDebit,
      isCredit,
      categoryPath,
      importPath,
      transactionAutomationPath,
      formatMoney,
      formatDate,
      formatDateTime,
      handleEdit,
      handleDelete,
    };
  },
};
</script>
