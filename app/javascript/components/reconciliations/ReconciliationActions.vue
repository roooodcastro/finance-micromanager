<template>
  <template v-if="reconciliation.status === 'in_progress'">
    <div
      v-if="!buttons"
      class="vr mx-3 d-none d-lg-flex"
    />

    <a
      v-if="showFinish"
      :class="{
        'd-flex align-items-center justify-content-center bg-primary text-white': drawerMenu,
        'text-primary': !drawerMenu && !buttons,
        'btn btn-primary flex-grow-1': buttons,
      }"
      href="#"
      @click="handleFinish"
    >
      <FontAwesomeIcon
        icon="check"
        size="lg"
      />
      <span class="d-none d-lg-inline-block ms-2">
        {{ t('finish') }}
      </span>
    </a>

    <a
      :class="{
        'd-flex align-items-center justify-content-center bg-danger text-white': drawerMenu,
        'text-danger': !drawerMenu && !buttons,
        'btn btn-danger flex-grow-1': buttons,
      }"
      href="#"
      @click="handleCancel"
    >
      <FontAwesomeIcon
        :icon="['far', 'trash-can']"
        size="lg"
      />
      <span class="d-none d-lg-inline-block ms-2">
        {{ t('cancel') }}
      </span>
    </a>
  </template>
</template>

<script>
import { computed } from 'vue';
import { storeToRefs } from 'pinia';

import I18n from '~/utils/I18n.js';
import useReconciliationStore from '~/stores/ReconciliationStore.js';
import useModalStore from '~/stores/ModalStore.js';
import { formatMoney } from '~/utils/NumberFormatter.js';
import { formatDate } from '~/utils/DateUtils.js';

import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';

export default {
  components: {
    FontAwesomeIcon,
  },

  props: {
    reconciliation: {
      type: Object,
      required: true,
    },
    drawerMenu: {
      type: Boolean,
      default: false,
    },
    buttons: {
      type: Boolean,
      default: false,
    },
    showFinish: {
      type: Boolean,
      default: false,
    },
  },

  setup(props) {
    const t =  I18n.scopedTranslator('views.reconciliations.index');

    const reconciliationStore = useReconciliationStore();
    const modalStore = useModalStore();

    const { realBalancesSum, walletBalancesSum } = storeToRefs(reconciliationStore);

    const differenceSum = computed(() => realBalancesSum.value - walletBalancesSum.value);

    const handleCancel = () => {
      modalStore
        .showConfirmationDialog({ message: t('confirm_cancel_message') })
        .then(() => reconciliationStore.cancel(props.reconciliation.id))
        .catch(() => {});
    };

    const handleFinish = () => {
      const message = differenceSum.value === 0
        ? t('confirm_finish_message')
        : t('confirm_finish_message_with_balance', {
          date: formatDate(props.reconciliation.date),
          amount: formatMoney(differenceSum.value),
        });
      modalStore
        .showConfirmationDialog({ message })
        .then(() => reconciliationStore.finish(props.reconciliation.id))
        .catch(() => {});
    };

    return {
      t,
      handleCancel,
      handleFinish,
    };
  },
};
</script>
