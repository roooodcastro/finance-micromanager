<template>
  <BarChart
    :labels="chartLabels"
    :datasets="chartDatasets"
    :datalabels-options="datalabelsOptions"
    :tooltip-label-formatter="tooltipFormatter"
    :y-ticks-formatter="yTicksFormatter"
    class="BudgetHistoryChart"
  />
</template>

<script>
import { computed, ref, onMounted, onUnmounted } from 'vue';
import { storeToRefs } from 'pinia';
import dayjs from 'dayjs';
import _ from 'lodash';

import I18n from '~/utils/I18n.js';
import { formatMoney } from '~/utils/NumberFormatter.js';
import { isMediaBreakpointUp } from '~/utils/ResponsivenessUtils.js';
import useBudgetInstanceStore from '~/stores/BudgetInstanceStore.js';

import BarChart from '~/components/ui/BarChart.vue';

export default {
  components: {
    BarChart,
  },

  setup() {
    const t = I18n.scopedTranslator('views.components.budget_history_chart');

    const isMediaBreakpointLgOrUpper = ref('');
    const textCreditColor = ref('');
    const textDebitColor = ref('');

    const budgetInstanceStore = useBudgetInstanceStore();

    const { budgetInstancesForHistory } = storeToRefs(budgetInstanceStore);

    const chartLabels = computed(() => {
      return budgetInstancesForHistory.value
        .map(budgetInstance => budgetInstance.startDate)
        .sort()
        .map(date => _.upperFirst(dayjs(date).format('MMM YYYY')));
    });

    const chartDatasets = computed(() => {
      const limitsData = budgetInstancesForHistory.value.map(budgetInstance => budgetInstance.limitAmount);
      const usedAmountsData = budgetInstancesForHistory.value.map(budgetInstance => budgetInstance.usedAmount);

      const limitsDataset = {
        data: limitsData,
        type: 'line',
        spanGaps: true,
        borderWidth: 2,
        borderColor: '#808080FF',
        backgroundColor: '#808080FF',
        label: t('limit_label'),
      };

      const usedAmountsDataset = {
        data: usedAmountsData,
        backgroundColor: usedAmountsData.map((amount, index) => {
          return amount <= limitsData[index] ? textCreditColor.value : textDebitColor.value;
        }) || [],
        label: t('used_label'),
      };

      return [limitsDataset, usedAmountsDataset];
    });

    const datalabelsOptions = computed(() => {
      return {
        anchor: 'start',
        align: 'end',
        formatter: value => formatMoney(value.toFixed(), { includeCents: false }),
        display: isMediaBreakpointLgOrUpper.value ? 'auto' : false,
      };
    });

    const tooltipFormatter = tooltip =>  `${tooltip.dataset.label}: ${formatMoney(tooltip.raw)}`;
    const yTicksFormatter = label => formatMoney(label, { includeCents: false });
    const updateColorVariables = () => {
      textCreditColor.value = getComputedStyle(document.documentElement).getPropertyValue('--chart-credit-color');
      textDebitColor.value = getComputedStyle(document.documentElement).getPropertyValue('--chart-debit-color');
    };

    onMounted(() => {
      updateColorVariables();
      isMediaBreakpointLgOrUpper.value = isMediaBreakpointUp('lg');

      document.body.addEventListener('themeChanged', updateColorVariables);

      window.addEventListener('resize', () => {
        isMediaBreakpointLgOrUpper.value = isMediaBreakpointUp('lg');
      });
    });

    onUnmounted(() => {
      window.removeEventListener('resize');
      document.body.removeEventListener('themeChanged');
    });

    return {
      chartLabels,
      chartDatasets,
      datalabelsOptions,
      tooltipFormatter,
      yTicksFormatter,
    };
  },
};
</script>

<style lang="scss" scoped>
.BudgetHistoryChart {
  height: 12.4rem;
}
</style>
