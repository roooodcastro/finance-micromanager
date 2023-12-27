<template>
  <template v-if="reconciliation.status === 'in_progress'">
    <div class="vr mx-3 d-none d-lg-flex" />

    <a
      :class="{
        'd-flex align-items-center justify-content-center bg-danger text-white': drawerMenu,
        'text-danger': !drawerMenu,
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
import I18n from '~/utils/I18n.js';
import useReconciliationStore from '~/stores/ReconciliationStore.js';
import useModalStore from '~/stores/ModalStore.js';

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
  },

  setup(props) {
    const t =  I18n.scopedTranslator('views.reconciliations.index');

    const reconciliationStore = useReconciliationStore();
    const modalStore = useModalStore();

    const handleCancel = () => {
      modalStore
        .showConfirmationDialog({ message: t('confirm_cancel_message') })
        .then(() => reconciliationStore.cancel(props.reconciliation.id))
        .catch(() => {});
    };


    return {
      t,
      handleCancel,
    };
  },
};
</script>
