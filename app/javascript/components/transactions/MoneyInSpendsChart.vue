<template>
  <BarChart
    ref="chart"
    :data="chartData"
    :options="chartOptions"
    class="MoneyInSpendsChart"
  />
</template>

<script>
import { computed, ref } from 'vue';
import { storeToRefs } from 'pinia';
import {
  Chart as ChartJS,
  BarElement,
  BarController,
  LinearScale,
} from 'chart.js';
import ChartDataLabels from 'chartjs-plugin-datalabels';

import I18n from '~/utils/I18n.js';
import useTransactionStore from '~/stores/TransactionStore.js';
import { formatMoney } from '~/utils/NumberFormatter.js';

import { Bar as BarChart } from 'vue-chartjs';

const MONEY_IN_COLOR = '#268c4d80';
const SPENDS_COLOR = '#d9534f80';

export default {
  components: {
    BarChart,
  },

  setup() {
    const chart = ref(null);

    const t = I18n.scopedTranslator('views.dashboard.show');
    const transactionStore = useTransactionStore();

    const { statistics } = storeToRefs(transactionStore);

    ChartJS.register(
      BarElement,
      BarController,
      LinearScale,
      ChartDataLabels,
    );

    const chartData = computed(() => {
      return {
        labels: [t('money_in'), t('spends')],
        datasets: [{
          data: [statistics.value.moneyIn, statistics.value.spends * -1],
          backgroundColor: [MONEY_IN_COLOR, SPENDS_COLOR],
        }],
      };
    });

    const chartOptions = {
      animation: {
        duration: 200,
      },
      maintainAspectRatio: false,
      layout: {
        padding: 0,
      },
      plugins: {
        datalabels: {
          align: 'center',
          offset: 0,
          clamp: true,
          formatter: value => formatMoney(value),
        },
      },
      scales: {
        x: {
          grid: {
            display: false,
          },
        },
        y: {
          display: false,
        },
      },
    };

    return {
      t,
      chart,
      chartData,
      chartOptions,
    };
  }
};
</script>

<style lang="scss" scoped>
.MoneyInSpendsChart {
  height: 9.5rem;
}
</style>
