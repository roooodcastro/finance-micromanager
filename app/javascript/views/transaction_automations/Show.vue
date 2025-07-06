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
      <BCard :title="t('sub_header_summary')">
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
            {{ formatMoney(transactionAutomationFromStore.transactionAmount) }}
          </dd>
          <dt class="col-6 col-md-4 my-1">
            {{ t('transaction_category') }}
          </dt>
          <dd class="col-6 col-md-8 my-1">
            <a :href="categoryPath(transactionAutomationFromStore.transactionCategoryId)">
              {{ transactionAutomationFromStore.transactionSubcategory?.displayName ?? transactionAutomationFromStore.transactionCategory.name }}
            </a>
          </dd>
          <dt class="col-6 col-md-4 my-1">
            {{ t('transaction_wallet') }}
          </dt>
          <dd class="col-6 col-md-8 my-1">
            <template v-if="transactionAutomationFromStore.transactionWallet">
              {{ transactionAutomationFromStore.transactionWallet.name }}
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
            <template v-if="!isCustomRule">
              {{ t('every') }}
              {{ transactionAutomationFromStore.scheduleInterval }}
              {{ I18n.t(`activerecord.attributes.transaction_automation.schedule_types.${transactionAutomationFromStore.scheduleTypeKey}`) }}
            </template>
            <template v-else>
              {{ t('every') }}
              {{ I18n.t(`activerecord.attributes.transaction_automation.schedule_custom_rule.${transactionAutomationFromStore.scheduleCustomRule}`) }}
            </template>
          </dd>
          <dt class="col-6 col-md-4 my-1">
            {{ t('scheduled_date') }}
          </dt>
          <dd class="col-6 col-md-8 my-1">
            {{ isDisabled ? t('no_next_run') : formatDate(transactionAutomationFromStore.scheduledDate) }}
          </dd>
        </dl>
      </BCard>
    </div>

    <div class="col-12 col-xl-6 mt-3 mt-xl-0">
      <BCard
        :title="t('sub_header_transactions')"
        no-body
      >
        <TransactionsList
          compact
          card-body
        />
      </BCard>
    </div>
  </div>

  <TransactionAutomationForm />
</template>

<script>
import { computed, watch } from 'vue';
import { storeToRefs } from 'pinia';

import I18n from '~/utils/I18n.js';
import {
  categories as categoriesApi,
  transactionAutomations as transactionAutomationsApi,
} from '~/api/all.js';
import useTransactionAutomationStore from '~/stores/TransactionAutomationStore.js';
import useProfileStore from '~/stores/ProfileStore.js';
import useTransactionStore from '~/stores/TransactionStore.js';
import useFloatingActionButtonStore from '~/stores/FloatingActionButtonStore.js';
import { formatMoney } from '~/utils/NumberFormatter.js';
import { formatDate } from '~/utils/DateUtils.js';
import { ICON_TRANSACTION_AUTOMATIONS } from '~/utils/Constants.js';

import PageHeader from '~/components/layout/PageHeader.vue';
import TransactionsList from '~/components/transactions/TransactionsList.vue';
import DropdownMenuItem from '~/components/ui/DropdownMenuItem.vue';
import TransactionAutomationForm from '~/components/transaction_automations/TransactionAutomationForm.vue';
import WarningAlert from '~/components/bootstrap/WarningAlert.vue';
import BCard from '~/components/bootstrap/BCard.vue';

export default {
  components: {
    BCard,
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
    transactionAutomationStore.setActionName('show');

    const floatingActionButtonStore = useFloatingActionButtonStore();
    floatingActionButtonStore.registerSpeedDialEntry({
      label: I18n.t('views.transaction_automations.floating_button_label'),
      icon: ICON_TRANSACTION_AUTOMATIONS,
      callback: () => transactionAutomationStore.openFormModal(null),
      shortcut: { keys: 'alt+n', keyLabels: ['alt', 'n'] },
    });

    const profileStore = useProfileStore();
    const { currentProfile } = storeToRefs(profileStore);
    watch(currentProfile, () => window.location.href = transactionAutomationsApi.index.path());

    // Load transaction automation from props
    const { transactionAutomation: transactionAutomationFromStore } = storeToRefs(transactionAutomationStore);
    transactionAutomationFromStore.value = props.transactionAutomation;

    const transactionStore = useTransactionStore();
    transactionStore.setFetchParams({
      transactionAutomationId: props.transactionAutomation.id,
      daysToShow: 0,
      startDate: null,
      endDate: null,
    });
    transactionStore.fetchCollection();

    const isDisabled = computed(() => !!transactionAutomationFromStore.value.disabledAt);
    const isDebit = computed(() => transactionAutomationFromStore.value.transactionAmount < 0);
    const isCredit = computed(() => transactionAutomationFromStore.value.transactionAmount > 0);
    const isCustomRule = computed(() => transactionAutomationFromStore.value.scheduleType === 'C');

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
      isCustomRule,
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
