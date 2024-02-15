<template>
  <div
    :id="DAILY_TOTALS_CHART_MODE_MODAL_ID"
    class="modal"
    tabindex="-1"
  >
    <div class="modal-dialog">
      <div class="modal-content">
        <div class="modal-header">
          <h5 class="modal-title">
            {{ t('mode_modal_title') }}
          </h5>
        </div>
        <div class="modal-body">
          <FormSelect
            field-name="mode"
            :options="options"
            :value="selectedMode"
            @change="handleChange"
          />
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { onMounted, ref } from 'vue';
import I18n from '~/utils/I18n.js';
import { DAILY_TOTALS_CHART_MODE_MODAL_ID, DISPLAY_OPTIONS_COOKIE_NAME } from '~/utils/Constants.js';
import useModalStore from '~/stores/ModalStore.js';
import { getValueFromJsonCookie, setValueToJsonCookie } from '~/utils/CookieUtils.js';

import FormSelect from '~/components/forms/FormSelect.vue';

export default {
  components: {
    FormSelect
  },

  emits: ['change'],

  setup(_, { emit }) {
    const t = I18n.scopedTranslator('views.statistics.daily_totals_chart');
    const options = [
      { label: t('mode_combined'), value: 'combined' },
      { label: t('mode_spends'), value: 'spends' },
      { label: t('mode_income'), value: 'income' },
      { label: t('mode_both'), value: 'both' },
    ]

    const selectedMode = ref(getValueFromJsonCookie(DISPLAY_OPTIONS_COOKIE_NAME, 'dailyTotalsChartMode'));
    const modalStore = useModalStore();

    onMounted(() => modalStore.registerModal(DAILY_TOTALS_CHART_MODE_MODAL_ID));

    const handleChange = (newMode) => {
      setValueToJsonCookie(DISPLAY_OPTIONS_COOKIE_NAME, 'dailyTotalsChartMode', newMode);
      selectedMode.value = newMode;
      emit('change', newMode);
      modalStore.hide(DAILY_TOTALS_CHART_MODE_MODAL_ID);
    };

    return {
      t,
      selectedMode,
      options,
      handleChange,
      DAILY_TOTALS_CHART_MODE_MODAL_ID,
    }
  }
};
</script>
