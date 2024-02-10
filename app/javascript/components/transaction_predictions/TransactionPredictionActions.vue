<template>
  <div class="vr mx-3 d-none d-lg-flex" />

  <template v-if="isDisabled">
    <DrawerContextMenuLink
      variant="success"
      icon="repeat"
      href="#"
      :label="t('reenable_label')"
      :drawer="drawerMenu"
      :class="{ 'TransactionPredictionActions__reenable-button': !drawerMenu }"
      @click="handleReenable"
    />
  </template>
  <template v-else>
    <EditButton
      small
      compact
      :href="editPath"
      :class="{ 'd-flex align-items-center justify-content-center bg-secondary text-white': drawerMenu }"
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
import { transactionPredictions as transactionPredictionsApi } from '~/api/all.js';
import useTransactionPredictionStore from '~/stores/TransactionPredictionStore.js';

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
    transactionPrediction: {
      type: Object,
      required: true,
    },
    drawerMenu: {
      type: Boolean,
      default: false,
    },
  },

  setup(props) {
    const t = I18n.scopedTranslator('views.transaction_predictions.list');
    const transactionPredictionStore = useTransactionPredictionStore();
    const editPath = transactionPredictionsApi.edit.path({ id: props.transactionPrediction.id });

    const isDisabled = computed(() => !!props.transactionPrediction.disabledAt);

    const handleDisable = () => transactionPredictionStore.disable(props.transactionPrediction.id);
    const handleReenable = () => transactionPredictionStore.reenable(props.transactionPrediction.id);

    return {
      t,
      editPath,
      isDisabled,
      handleDisable,
      handleReenable,
    };
  },
};
</script>

<style lang="scss" scoped>
@import '../../stylesheets/variables';

.TransactionPredictionActions__reenable-button {
  background-color: $light-bg-subtle;
  margin: -0.5rem -0.5rem -0.5rem -1rem;
  padding: 0.5rem 0.5rem 0.5rem 1rem;
}
</style>
