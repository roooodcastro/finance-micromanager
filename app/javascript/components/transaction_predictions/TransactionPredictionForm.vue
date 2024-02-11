<template>
  <RailsForm
    :id="TRANSACTION_PREDICTION_FORM_ID"
    :action="formAction"
    :method="formMethod"
    resource="transaction_prediction"
  >
    <template v-slot:default="{ formHelper }">
      <input
        :id="formHelper.fieldId('rules_json')"
        v-model="transactionPredictionFromStore.rulesJson"
        :name="formHelper.fieldName('rules_json')"
        type="hidden"
      >

      <h5 class="my-3">
        {{ t('name_label') }}
      </h5>

      <FormInput
        v-model="transactionPredictionFromStore.name"
        field-name="name"
        :form-helper="formHelper"
        required
      />

      <h5 class="my-3">
        {{ t('sub_header_conditions') }}
      </h5>


      <div class="card card-body">
        <div class="d-flex flex-row align-items-center flex-wrap gap-2">
          <div
            v-for="(_, index) in rulesParser.conditions.length"
            :key="`condition-${index}`"
            class="d-flex align-items-center gap-2"
          >
            <span v-if="index > 0">{{ t('label_or') }}</span>
            <TransactionPredictionCondition :condition-index="index" />
          </div>
        </div>

        <a
          href="#"
          class="mt-3"
          @click="handleNewCondition"
        >
          {{ t('new_condition') }}
        </a>
      </div>

      <h5 class="my-3">
        {{ t('sub_header_action') }}
      </h5>

      <div class="card card-body">
        <div class="d-flex flex-row align-items-center flex-wrap gap-2">
          <div
            v-for="(_, index) in rulesParser.actions.length"
            :key="`action-${index}`"
            class="d-flex align-items-center gap-2"
          >
            <span v-if="index > 0">{{ t('label_and') }}</span>
            <TransactionPredictionAction :action-index="index" />
          </div>
        </div>

        <a
          href="#"
          class="mt-3"
          @click="handleNewAction"
        >
          {{ t('new_action') }}
        </a>
      </div>

      <hr>

      <div class="d-grid d-md-block">
        <button
          type="submit"
          class="btn btn-primary"
        >
          <FontAwesomeIcon
            icon="floppy-disk"
            class="me-lg-2"
          />

          {{ t('submit') }}
        </button>
      </div>
    </template>
  </RailsForm>

  <TransactionPredictionConditionModal />
  <TransactionPredictionActionModal />
</template>

<script>
import { computed } from 'vue';
import { storeToRefs } from 'pinia';
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';

import I18n from '~/utils/I18n.js';
import { transactionPredictions as transactionPredictionsApi } from '~/api/all.js';
import useCategoryStore from '~/stores/CategoryStore.js';
import useWalletStore from '~/stores/WalletStore.js';
import useTransactionPredictionsStore from '~/stores/TransactionPredictionStore.js';
import useModalStore from '~/stores/ModalStore.js';
import { RulesParser } from '~/lib/transaction_predictions/RulesParser.js';
import {
  TRANSACTION_PREDICTION_CONDITION_MODAL_ID,
  TRANSACTION_PREDICTION_ACTION_MODAL_ID,
  TRANSACTION_PREDICTION_FORM_ID,
} from '~/utils/Constants.js';

import RailsForm from '~/components/rails/RailsForm.vue';
import FormInput from '~/components/rails/FormInput.vue';
import TransactionPredictionConditionModal from '~/components/transaction_predictions/TransactionPredictionConditionModal.vue';
import TransactionPredictionCondition from '~/components/transaction_predictions/TransactionPredictionCondition.vue';
import TransactionPredictionAction from '~/components/transaction_predictions/TransactionPredictionAction.vue';
import TransactionPredictionActionModal from '~/components/transaction_predictions/TransactionPredictionActionModal.vue';

export default {
  components: {
    FontAwesomeIcon,
    FormInput,
    RailsForm,
    TransactionPredictionAction,
    TransactionPredictionActionModal,
    TransactionPredictionCondition,
    TransactionPredictionConditionModal,
  },

  props: {
    transactionPrediction: {
      type: Object,
      required: true,
    },
  },

  setup(props) {
    const t = I18n.scopedTranslator('views.transaction_predictions.form');

    const modalStore = useModalStore();
    const categoryStore = useCategoryStore();
    const walletStore = useWalletStore();
    const transactionPredictionStore = useTransactionPredictionsStore();

    const { categories } = storeToRefs(categoryStore);
    const { activeWallets } = storeToRefs(walletStore);
    const {
      transactionPrediction: transactionPredictionFromStore,
      currentConditionIndex,
      currentActionIndex,
    } = storeToRefs(transactionPredictionStore);

    transactionPredictionFromStore.value = props.transactionPrediction;

    const rulesParser = computed(() => new RulesParser(transactionPredictionFromStore.value.rulesJson));

    if (!categories.value.length) {
      categoryStore.fetchCollection();
    }

    if (!activeWallets.value.length) {
      walletStore.fetchCollection();
    }

    const isNewRecord = computed(() => !transactionPredictionFromStore.value.id);
    const formTitle = computed(() => isNewRecord.value ? t('new_title') : t('edit_title'));
    const formMethod = computed(() => isNewRecord.value ? 'POST' : 'PATCH');
    const formAction = computed(() => {
      return isNewRecord.value
        ? transactionPredictionsApi.create.path()
        : transactionPredictionsApi.update.path({ id: transactionPredictionFromStore.value.id });
    });

    const handleNewCondition = () => {
      currentConditionIndex.value = rulesParser.value.conditions.length;
      modalStore.show(TRANSACTION_PREDICTION_CONDITION_MODAL_ID);
    };

    const handleNewAction = () => {
      currentActionIndex.value = rulesParser.value.actions.length;
      modalStore.show(TRANSACTION_PREDICTION_ACTION_MODAL_ID);
    };

    return {
      t,
      rulesParser,
      formTitle,
      formMethod,
      formAction,
      transactionPredictionFromStore,
      handleNewCondition,
      handleNewAction,
      TRANSACTION_PREDICTION_FORM_ID,
    };
  },
};
</script>

<style lang="scss" scoped>
.TransactionPredictionForm__schedule-grid {
  grid-template-columns: repeat(2, 1fr);
}
</style>
