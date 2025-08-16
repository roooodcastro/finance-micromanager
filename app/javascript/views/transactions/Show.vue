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
        <dl class="row mb-0">
          <DescriptionListItem :title="t('name_label')">
            {{ transactionFromStore.name }}
          </DescriptionListItem>
          <DescriptionListItem
            :title="t('amount_label')"
            :details-class="{ 'text-credit': isCredit, 'text-debit': isDebit }"
          >
            {{ formatMoney(transactionFromStore.amount) }}
          </DescriptionListItem>
          <DescriptionListItem :title="t('date_label')">
            {{ formatDate(transactionFromStore.transactionDate) }}
          </DescriptionListItem>
          <DescriptionListItem :title="t('category_label')">
            <CategoryBadge
              :category="transactionFromStore.category"
              :subcategory="transactionFromStore.subcategory"
            />
          </DescriptionListItem>
          <DescriptionListItem :title="t('wallet_label')">
            <WalletBadge :wallet="transactionFromStore.wallet" />
          </DescriptionListItem>
          <DescriptionListItem
            v-if="!!budgetInstance"
            :title="t('budget_percentage_label')"
            :details-class="{ 'text-credit': usedBudgetPercentage > 0, 'text-debit': usedBudgetPercentage < -100 }"
          >
            {{ Math.abs(usedBudgetPercentage).toFixed(1) }}%
            {{ t('of_label') }}
            {{ formatMoney(budgetInstance.limitAmount) }}
          </DescriptionListItem>
          <DescriptionListItem
            v-if="!!transactionFromStore.transactionAutomationId"
            :title="t('transaction_automation_label')"
          >
            <a :href="transactionAutomationPath(transactionFromStore.transactionAutomationId)">
              <Badge
                i18n-scope="views.transactions.show.transaction_automation_value"
                icon="robot"
                class="text-decoration-underline"
              />
            </a>
          </DescriptionListItem>
          <DescriptionListItem
            v-if="!!transactionFromStore.importId"
            :title="t('import_label')"
          >
            <a :href="importPath(transactionFromStore.importId)">
              {{ t('import_value') }}
            </a>
          </DescriptionListItem>
        </dl>

        <hr class="d-none d-sm-block my-3">

        <dl class="row">
          <DescriptionListItem :title="t('created_at_label')">
            {{ formatDateTime(transactionFromStore.createdAt) }}
          </DescriptionListItem>
          <DescriptionListItem :title="t('created_by_label')">
            {{ transactionFromStore.createdBy?.displayName }}
          </DescriptionListItem>
          <template v-if="transactionFromStore.createdAt != transactionFromStore.updatedAt">
            <DescriptionListItem :title="t('updated_at_label')">
              {{ formatDateTime(transactionFromStore.updatedAt) }}
            </DescriptionListItem>
            <DescriptionListItem :title="t('updated_by_label')">
              {{ transactionFromStore.updatedBy?.displayName }}
            </DescriptionListItem>
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
  imports as importsApi,
  transactions as transactionsApi,
  transactionAutomations as transactionAutomationsApi,
} from '~/api/all.js';
import { formatMoney } from '~/utils/NumberFormatter.js';
import { formatDate, formatDateTime } from '~/utils/DateUtils.js';
import useTransactionStore from '~/stores/TransactionStore.js';
import useBudgetInstanceStore from '~/stores/BudgetInstanceStore.js';
import { onProfileChangedRedirectToIndex } from '~/utils/OnProfileChangeWatcher.js';

import PageHeader from '~/components/layout/PageHeader.vue';
import DropdownMenuItem from '~/components/ui/DropdownMenuItem.vue';
import BCard from '~/components/bootstrap/BCard.vue';
import CategoryBadge from '~/components/categories/CategoryBadge.vue';
import Badge from '~/components/ui/Badge.vue';
import DescriptionListItem from '~/components/layout/DescriptionListItem.vue';
import WalletBadge from '~/components/wallets/WalletBadge.vue';

export default {
  components: {
    Badge,
    BCard,
    CategoryBadge,
    DescriptionListItem,
    DropdownMenuItem,
    PageHeader,
    WalletBadge,
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
    const importPath = id => importsApi.show.path({ id });
    const transactionAutomationPath = id => transactionAutomationsApi.show.path({ id });

    const transactionStore = useTransactionStore();
    transactionStore.setActionName('show');

    const budgetInstanceStore = useBudgetInstanceStore();
    const { budgetInstanceForCategory } = storeToRefs(budgetInstanceStore);
    const budgetInstance = computed(() => budgetInstanceForCategory.value(props.transaction.categoryId));
    budgetInstanceStore.setFetchParams({
      startDate: props.transaction.transactionDate,
      endDate: props.transaction.transactionDate
    });
    budgetInstanceStore.fetchCollection();

    const usedBudgetPercentage = computed(() => {
      return 100 * (props.transaction.amount / budgetInstance.value.limitAmount);
    });

    const { transaction: transactionFromStore, transactions } = storeToRefs(transactionStore);
    transactionFromStore.value = props.transaction;
    transactions.value = [props.transaction];

    const isDebit = computed(() => transactionFromStore.value.amount < 0);
    const isCredit = computed(() => transactionFromStore.value.amount > 0);

    onProfileChangedRedirectToIndex(transactionsApi);

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
      budgetInstance,
      usedBudgetPercentage,
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
