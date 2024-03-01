<template>
  <div>
    <PageHeader :title="t('title')">
      <template v-slot:actions>
        <DropdownMenuItem
          :label="t('new')"
          icon="plus"
          @click="handleNew"
        />
      </template>
    </PageHeader>

    <TransactionAutomationForm />
    <TransactionAutomationsList />
  </div>
</template>

<script>
import { watch } from 'vue';
import { storeToRefs } from 'pinia';

import I18n from '~/utils/I18n.js';
import useProfileStore from '~/stores/ProfileStore.js';
import useTransactionAutomationStore from '~/stores/TransactionAutomationStore.js';
import useFloatingActionButtonStore from '~/stores/FloatingActionButtonStore.js';
import { ICON_TRANSACTION_AUTOMATIONS } from '~/utils/Constants.js';

import PageHeader from '~/components/layout/PageHeader.vue';
import DropdownMenuItem from '~/components/ui/DropdownMenuItem.vue';
import TransactionAutomationForm from '~/components/transaction_automations/TransactionAutomationForm.vue';
import TransactionAutomationsList from '~/components/transaction_automations/TransactionAutomationsList.vue';

export default {
  components: {
    DropdownMenuItem,
    TransactionAutomationForm,
    TransactionAutomationsList,
    PageHeader,
  },

  props: {
    transactionAutomations: {
      type: Array,
      required: true,
    },
  },

  setup(props) {
    const transactionAutomationStore = useTransactionAutomationStore();
    transactionAutomationStore.setActionName('index');

    const floatingActionButtonStore = useFloatingActionButtonStore();
    floatingActionButtonStore.registerSpeedDialEntry({
      label: I18n.t('views.transaction_automations.floating_button_label'),
      icon: ICON_TRANSACTION_AUTOMATIONS,
      callback: () => transactionAutomationStore.openFormModal(null),
    });

    const profileStore = useProfileStore();
    const { currentProfile } = storeToRefs(profileStore);
    watch(currentProfile, () => transactionAutomationStore.fetchCollection());

    transactionAutomationStore.loadCollectionFromProps(props.transactionAutomations);

    const handleNew = () => transactionAutomationStore.openFormModal(null);

    return {
      t: I18n.scopedTranslator('views.transaction_automations.index'),
      handleNew,
    };
  },
};
</script>
