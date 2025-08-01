<template>
  <PageHeader
    :sub-title="t('title')"
    :back-button-href="indexPath"
  >
    <div class="d-flex gap-3 align-items-center">
      {{ transactionPredictionFromStore.name }}

      <Badge
        v-if="isDisabled"
        type="disabled"
        class="fs-5"
      />
    </div>

    <template v-slot:actions>
      <DropdownMenuItem
        :label="t('edit')"
        icon="pen-to-square"
        :href="editPath"
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

  <BCard :title="t('sub_header_rules')">
    <h5 class="mt-5 mb-3">
      {{ t('sub_header_conditions') }}
    </h5>

    <div class="d-flex flex-row align-items-center flex-wrap gap-2">
      <TransactionPredictionCondition
        v-for="(_, index) in rulesParser.conditions.length"
        :key="`condition-${index}`"
        :condition-index="index"
        :disabled="isDisabled"
        class="w-100"
      />
    </div>

    <h5 class="mt-5 mb-3">
      {{ t('sub_header_action') }}
    </h5>

    <div class="d-flex flex-row align-items-center flex-wrap gap-2">
      <TransactionPredictionAction
        v-for="(_, index) in rulesParser.actions.length"
        :key="`action-${index}`"
        :action-index="index"
        :disabled="isDisabled"
        class="w-100"
      />
    </div>
  </BCard>
</template>

<script>
import { computed } from 'vue';
import { storeToRefs } from 'pinia';

import I18n from '~/utils/I18n.js';
import { transactionPredictions as transactionPredictionsApi } from '~/api/all.js';
import useTransactionPredictionStore from '~/stores/TransactionPredictionStore.js';
import useCategoryStore from '~/stores/CategoryStore.js';
import useWalletStore from '~/stores/WalletStore.js';
import useFloatingActionButtonStore from '~/stores/FloatingActionButtonStore.js';
import { RulesParser } from '~/lib/transaction_predictions/RulesParser.js';
import { ICON_TRANSACTION_PREDICTIONS } from '~/utils/Constants.js';
import { onProfileChangedRedirectToIndex } from '~/utils/OnProfileChangeWatcher.js';

import PageHeader from '~/components/layout/PageHeader.vue';
import DropdownMenuItem from '~/components/ui/DropdownMenuItem.vue';
import WarningAlert from '~/components/bootstrap/WarningAlert.vue';
import TransactionPredictionAction from '~/components/transaction_predictions/TransactionPredictionAction.vue';
import TransactionPredictionCondition from '~/components/transaction_predictions/TransactionPredictionCondition.vue';
import BCard from '~/components/bootstrap/BCard.vue';
import Badge from '~/components/ui/Badge.vue';

export default {
  components: {
    Badge,
    BCard,
    DropdownMenuItem,
    PageHeader,
    TransactionPredictionAction,
    TransactionPredictionCondition,
    WarningAlert,
  },

  props: {
    transactionPrediction: {
      type: Object,
      required: true,
    },
  },

  setup(props) {
    const t = I18n.scopedTranslator('views.transaction_predictions.show');

    const indexPath = transactionPredictionsApi.index.path();
    const newPath = transactionPredictionsApi.new.path();
    const editPath = transactionPredictionsApi.edit.path({ id: props.transactionPrediction.id });

    const categoryStore = useCategoryStore();
    const walletStore = useWalletStore();
    const transactionPredictionStore = useTransactionPredictionStore();

    const { categories } = storeToRefs(categoryStore);
    const { activeWallets } = storeToRefs(walletStore);

    if (!categories.value.length) {
      categoryStore.fetchCollection();
    }

    if (!activeWallets.value.length) {
      walletStore.fetchCollection();
    }

    const floatingActionButtonStore = useFloatingActionButtonStore();
    floatingActionButtonStore.registerSpeedDialEntry({
      label: I18n.t('views.transaction_predictions.floating_button_label'),
      icon: ICON_TRANSACTION_PREDICTIONS,
      href: newPath,
      shortcut: { keys: 'alt+n', keyLabels: ['alt', 'n'] },
    });

    onProfileChangedRedirectToIndex(transactionPredictionsApi);

    // Load transaction prediction from props
    const { transactionPrediction: transactionPredictionFromStore } = storeToRefs(transactionPredictionStore);
    transactionPredictionFromStore.value = props.transactionPrediction;

    const rulesParser = computed(() => new RulesParser(transactionPredictionFromStore.value.rulesJson));
    const isDisabled = computed(() => !!transactionPredictionFromStore.value.disabledAt);

    const handleDisable = () => transactionPredictionStore.disable(props.transactionPrediction.id);
    const handleDelete = () => transactionPredictionStore.destroy(props.transactionPrediction.id);
    const handleReenable = () => transactionPredictionStore.reenable(props.transactionPrediction.id);

    return {
      I18n,
      t,
      indexPath,
      editPath,
      rulesParser,
      transactionPredictionFromStore,
      isDisabled,
      handleDisable,
      handleDelete,
      handleReenable,
    };
  },
};
</script>
