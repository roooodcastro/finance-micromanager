<template>
  <div>
    <PageHeader :title="t('title')">
      <template v-slot:actions>
        <DropdownMenuItem
          :label="t('new')"
          icon="plus"
          :href="newPath"
        />
      </template>
    </PageHeader>

    <TransactionPredictionsList />
  </div>
</template>

<script>
import { watch } from 'vue';
import { storeToRefs } from 'pinia';

import I18n from '~/utils/I18n.js';
import useProfileStore from '~/stores/ProfileStore.js';
import useTransactionPredictionStore from '~/stores/TransactionPredictionStore.js';
import useFloatingActionButtonStore from '~/stores/FloatingActionButtonStore.js';
import { transactionPredictions as transactionPredictionsApi } from '~/api/all.js';
import { ICON_TRANSACTION_PREDICTIONS } from '~/utils/Constants.js';

import PageHeader from '~/components/layout/PageHeader.vue';
import DropdownMenuItem from '~/components/ui/DropdownMenuItem.vue';
import TransactionPredictionsList from '~/components/transaction_predictions/TransactionPredictionsList.vue';

export default {
  components: {
    DropdownMenuItem,
    TransactionPredictionsList,
    PageHeader,
  },

  props: {
    transactionPredictions: {
      type: Array,
      required: true,
    },
  },

  setup(props) {
    const newPath = transactionPredictionsApi.new.path();

    const transactionPredictionStore = useTransactionPredictionStore();
    transactionPredictionStore.setActionName('index');

    const floatingActionButtonStore = useFloatingActionButtonStore();
    floatingActionButtonStore.registerSpeedDialEntry({
      label: I18n.t('views.transaction_predictions.floating_button_label'),
      icon: ICON_TRANSACTION_PREDICTIONS,
      href: newPath,
      shortcut: { keys: 'alt+n', keyLabels: ['alt', 'n'] },
    });

    const profileStore = useProfileStore();
    const { currentProfile } = storeToRefs(profileStore);
    watch(currentProfile, () => transactionPredictionStore.fetchCollection());

    transactionPredictionStore.loadCollectionFromProps(props.transactionPredictions);

    return {
      t: I18n.scopedTranslator('views.transaction_predictions.index'),
      newPath,
    };
  },
};
</script>
