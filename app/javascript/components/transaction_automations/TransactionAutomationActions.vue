<template>
  <div class="vr mx-3 d-none d-lg-flex" />

  <template v-if="isDisabled">
    <DrawerContextMenuLink
      variant="success"
      icon="repeat"
      href="#"
      :label="t('reenable_label')"
      :drawer="drawerMenu"
      :class="{ 'TransactionAutomationActions__reenable-button': !drawerMenu }"
      @click="handleReenable"
    />
  </template>
  <template v-else>
    <EditButton
      small
      compact
      href="#"
      :class="{ 'd-flex align-items-center justify-content-center bg-secondary text-white': drawerMenu }"
      @click="handleEdit"
    />

    <div class="vr mx-3 d-none d-lg-flex" />

    <DeleteButton
      small
      compact
      disable-label
      href="#"
      :class="{
        'd-flex align-items-center justify-content-center bg-danger text-white': drawerMenu,
        'me-0 me-lg-3': !drawerMenu,
      }"
      @delete="handleDisable"
    />
  </template>
</template>

<script>
import { computed } from 'vue';

import I18n from '~/utils/I18n.js';
import useTransactionAutomationStore from '~/stores/TransactionAutomationStore.js';

import EditButton from '~/components/rails/EditButton.vue';
import DeleteButton from '~/components/rails/DeleteButton.vue';
import DrawerContextMenuLink from '~/components/ui/DrawerContextMenuLink.vue';

export default {
  components: {
    DrawerContextMenuLink,
    DeleteButton,
    EditButton
  },

  props: {
    transactionAutomation: {
      type: Object,
      required: true,
    },
    drawerMenu: {
      type: Boolean,
      default: false,
    },
  },

  setup(props) {
    const t = I18n.scopedTranslator('views.transaction_automations.list');
    const transactionAutomationStore = useTransactionAutomationStore();

    const isDisabled = computed(() => !!props.transactionAutomation.disabledAt);

    const handleEdit = () => transactionAutomationStore.openFormModal(props.transactionAutomation.id);
    const handleDisable = () => transactionAutomationStore.disable(props.transactionAutomation.id);
    const handleReenable = () => transactionAutomationStore.reenable(props.transactionAutomation.id);

    return {
      t,
      handleEdit,
      handleDisable,
      handleReenable,
      isDisabled,
    };
  },
};
</script>

<style lang="scss" scoped>
@import '../../stylesheets/variables';

.TransactionAutomationActions__reenable-button {
  background-color: $light-bg-subtle;
  margin: -0.5rem -0.5rem -0.5rem -1rem;
  padding: 0.5rem 0.5rem 0.5rem 1rem;
}
</style>
