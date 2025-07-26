<template>
  <PageHeader
    :sub-title="t('title')"
    :back-button-href="transactionAutomationsPath"
  >
    <div class="d-flex gap-3 align-items-center">
      {{ transactionAutomationFromStore.transactionName }}

      <Badge
        v-if="isDisabled"
        type="disabled"
        i18n-scope="views.transaction_automations.show.disabled"
        class="fs-5 d-none d-md-block"
      />
    </div>

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
    class="m-3 mx-lg-0"
  />

  <div class="row">
    <div class="col-12 col-xl-6">
      <BCard :title="t('sub_header_summary')">
        <dl class="row mb-0">
          <DescriptionListItem :title="t('transaction_name')">
            {{ transactionAutomation.transactionName }}
          </DescriptionListItem>

          <DescriptionListItem
            :title="t('transaction_amount')"
            :details-class="{ 'text-muted': isDisabled, 'text-credit': isCredit && !isDisabled, 'text-debit': isDebit && !isDisabled }"
          >
            {{ formatMoney(transactionAutomationFromStore.transactionAmount) }}
          </DescriptionListItem>
          <DescriptionListItem :title="t('transaction_category')">
            <a :href="categoryPath(transactionAutomationFromStore.transactionCategoryId)">
              <CategoryBadge
                :category="transactionAutomationFromStore.transactionCategory"
                :subcategory="transactionAutomationFromStore.transactionSubcategory"
              />
            </a>
          </DescriptionListItem>
          <DescriptionListItem :title="t('transaction_wallet')">
            <template v-if="transactionAutomationFromStore.transactionWallet">
              {{ transactionAutomationFromStore.transactionWallet.name }}
            </template>
            <template v-else>
              {{ t('no_wallet') }}
            </template>
          </DescriptionListItem>
          <DescriptionListItem :title="t('scheduled_transaction_date')">
            {{ isDisabled ? t('no_next_run') : formatDate(transactionAutomationFromStore.scheduledDate) }}
          </DescriptionListItem>
        </dl>

        <hr class="d-none d-sm-block my-3">

        <dl class="row">
          <DescriptionListItem :title="t('schedule')">
            {{ transactionAutomationFromStore.humanizedSchedule }}
          </DescriptionListItem>
          <DescriptionListItem :title="t('when_to_run')">
            {{ !!transactionAutomationFromStore.createAtStartOfPeriod ? transactionAutomationFromStore.humanizedNextRun : t('run_on_transaction_date') }}
          </DescriptionListItem>
          <DescriptionListItem :title="t('next_run_at')">
            {{ isDisabled ? t('no_next_run') : formatDate(transactionAutomationFromStore.nextRunAt) }}
          </DescriptionListItem>
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
import Badge from '~/components/ui/Badge.vue';
import CategoryBadge from '~/components/categories/CategoryBadge.vue';
import DescriptionListItem from '~/components/layout/DescriptionListItem.vue';

export default {
  components: {
    Badge,
    BCard,
    CategoryBadge,
    DescriptionListItem,
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
