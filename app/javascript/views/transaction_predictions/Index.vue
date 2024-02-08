<template>
  <div>
    <PageHeader :title="t('title')">
      <template v-slot:actions>
        <DropdownMenuItem
          :label="t('new')"
          icon="plus"
          href="#"
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
    const transactionPredictionStore = useTransactionPredictionStore();
    transactionPredictionStore.setActionName('index');

    const floatingActionButtonStore = useFloatingActionButtonStore();
    floatingActionButtonStore.registerSpeedDialEntry({
      label: I18n.t('views.transaction_predictions.floating_button_label'),
      icon: 'wand-magic-sparkles',
      callback: () => transactionPredictionStore.openFormModal(null),
    });

    const profileStore = useProfileStore();
    const { currentProfile } = storeToRefs(profileStore);
    watch(currentProfile, () => transactionPredictionStore.fetchCollection());

    transactionPredictionStore.loadCollectionFromProps(props.transactionPredictions);

    return {
      t: I18n.scopedTranslator('views.transaction_predictions.index'),
    };
  },
};
</script>
