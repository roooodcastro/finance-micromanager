<template>
  <PageHeader
    :title="transactionAutomationFromStore.transactionName"
    :sub-title="t('title')"
    :back-button-href="transactionAutomationsPath"
  >
    <template v-slot:actions>
      <DropdownMenuItem
        :label="t('edit')"
        icon="pen-to-square"
        @click="handleEdit"
      />
      <DropdownMenuItem
        v-if="!isDisabled"
        :label="t('disable')"
        icon="ban"
        class="text-danger"
        @click="handleDisable"
      />
      <DropdownMenuItem
        v-if="isDisabled"
        :label="t('reenable')"
        icon="repeat"
        class="text-primary"
        @click="handleReenable"
      />

      <hr class="my-2">

      <DropdownMenuItem
        :label="t('destroy')"
        :icon="['far', 'trash-can']"
        class="text-bg-danger"
        @click="handleDelete"
      />
    </template>
  </PageHeader>

  <WarningAlert
    v-if="isDisabled"
    :title="t('disabled_alert_title')"
    :message="t('disabled_alert_message')"
  />

  <div class="row">
    <div class="col-12 col-xl-6">
      <div class="card">
        <div class="card-header">
          <h5 class="m-0">
            {{ t('sub_header_summary') }}
          </h5>
        </div>
        <div class="card-body">
          <dl class="row">
            <dt class="col-6 col-md-4 my-1">
              {{ t('transaction_name') }}
            </dt>
            <dd class="col-6 col-md-8 my-1">
              {{ transactionAutomation.transactionName }}
            </dd>
            <dt class="col-6 col-md-4 my-1">
              {{ t('transaction_amount') }}
            </dt>
            <dd
              class="col-6 col-md-8 my-1 fw-bold"
              :class="{ 'text-muted': isDisabled, 'text-credit': isCredit && !isDisabled, 'text-debit': isDebit && !isDisabled }"
            >
              {{ formatMoney(transactionAutomation.transactionAmount) }}
            </dd>
            <dt class="col-6 col-md-4 my-1">
              {{ t('transaction_category') }}
            </dt>
            <dd class="col-6 col-md-8 my-1">
              <a :href="categoryPath(transactionAutomation.transactionCategoryId)">
                {{ transactionAutomation.transactionSubcategory?.displayName ?? transactionAutomation.transactionCategory.name }}
              </a>
            </dd>
            <dt class="col-6 col-md-4 my-1">
              {{ t('transaction_wallet') }}
            </dt>
            <dd class="col-6 col-md-8 my-1">
              <template v-if="transactionAutomation.transactionWallet">
                {{ transactionAutomation.transactionWallet.name }}
              </template>
              <template v-else>
                {{ t('no_wallet') }}
              </template>
            </dd>
          </dl>

          <hr class="my-3">

          <dl class="row">
            <dt class="col-6 col-md-4 my-1">
              {{ t('schedule') }}
            </dt>
            <dd class="col-6 col-md-8 my-1">
              {{ t('every') }}
              {{ transactionAutomation.scheduleInterval }}
              {{ I18n.t(`activerecord.attributes.transaction_automation.schedule_types.${transactionAutomation.scheduleTypeKey}`) }}
            </dd>
            <dt class="col-6 col-md-4 my-1">
              {{ t('next_schedule_date') }}
            </dt>
            <dd class="col-6 col-md-8 my-1">
              {{ isDisabled ? t('no_next_run') : formatDate(transactionAutomation.nextScheduleDate) }}
            </dd>
            <dt class="col-6 col-md-4 my-1">
              {{ t('last_schedule_date') }}
            </dt>
            <dd class="col-6 col-md-8 my-1">
              {{ transactionAutomation.lastScheduleDate ? formatDate(transactionAutomation.lastScheduleDate) : t('no_last_run') }}
            </dd>
          </dl>
        </div>
      </div>
    </div>

    <div class="col-12 col-xl-6">
      <div class="card mt-3 mt-xl-0">
        <div class="card-header">
          <h5 class="m-0">
            {{ t('sub_header_transactions') }}
          </h5>
        </div>
        <TransactionsList
          compact
          card-body
        />
      </div>
    </div>
  </div>

  <TransactionAutomationForm />
</template>

<script>
import { computed } from 'vue';
import { storeToRefs } from 'pinia';

import I18n from '~/utils/I18n.js';
import {
  categories as categoriesApi,
  transactionAutomations as transactionAutomationsApi,
} from '~/api/all.js';
import useTransactionAutomationStore from '~/stores/TransactionAutomationStore.js';
import useTransactionStore from '~/stores/TransactionStore.js';
import { formatMoney } from '~/utils/NumberFormatter.js';
import { formatDate } from '~/utils/DateUtils.js';

import PageHeader from '~/components/layout/PageHeader.vue';
import TransactionsList from '~/components/transactions/TransactionsList.vue';
import DropdownMenuItem from '~/components/ui/DropdownMenuItem.vue';
import TransactionAutomationForm from '~/components/transaction_automations/TransactionAutomationForm.vue';
import WarningAlert from '~/components/bootstrap/WarningAlert.vue';

export default {
  components: {
    DropdownMenuItem,
    PageHeader,
    TransactionAutomationForm,
    TransactionsList,
    WarningAlert,
  },

  props: {
    transactionAutomation: {
      type: Object,
      required: true,
    },
  },

  setup(props) {
    const t = I18n.scopedTranslator('views.transaction_automations.show');

    const transactionAutomationsPath = transactionAutomationsApi.index.path();
    const categoryPath = id => categoriesApi.show.path({ id });

    const transactionAutomationStore = useTransactionAutomationStore();
    const transactionStore = useTransactionStore();

    // Load transaction automation from props
    const { transactionAutomation: transactionAutomationFromStore } = storeToRefs(transactionAutomationStore);
    transactionAutomationFromStore.value = props.transactionAutomation;
    transactionAutomationStore.fetch();

    transactionStore.setFetchParams({ categoryIds: props.transactionAutomation.id, daysToShow: 0 });
    transactionStore.fetch();

    const isDisabled = computed(() => !!transactionAutomationFromStore.value.disabledAt);
    const isDebit = computed(() => transactionAutomationFromStore.value.transactionAmount < 0);
    const isCredit = computed(() => transactionAutomationFromStore.value.transactionAmount > 0);

    const handleEdit = () => transactionAutomationStore.openFormModal(props.transactionAutomation.id);
    const handleDisable = () => transactionAutomationStore.disable(props.transactionAutomation.id);
    const handleDelete = () => transactionAutomationStore.destroy(props.transactionAutomation.id);
    const handleReenable = () => transactionAutomationStore.reenable(props.transactionAutomation.id);

    return {
      I18n,
      t,
      transactionAutomationsPath,
      transactionAutomationFromStore,
      isDisabled,
      isDebit,
      isCredit,
      categoryPath,
      formatMoney,
      formatDate,
      handleEdit,
      handleDisable,
      handleDelete,
      handleReenable,
    };
  },
};
</script>
