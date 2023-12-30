<template>
  <CollapsibleCard
    id="dashboard_show_day_chart"
    :title="t('sub_header_day_chart')"
  >
    <BarChart
      ref="chart"
      :data="chartData"
      :options="chartOptions"
    />
  </CollapsibleCard>
</template>

<script>
import { computed, nextTick, ref, watch } from 'vue';
import { storeToRefs } from 'pinia';
import dayjs from 'dayjs';
import {
  Chart as ChartJS,
  Tooltip,
  BarElement,
  BarController,
  CategoryScale,
  LinearScale,
} from 'chart.js';
import ChartDataLabels from 'chartjs-plugin-datalabels';
import AnnotationPlugin from 'chartjs-plugin-annotation';

import I18n from '~/utils/I18n.js';
import useTransactionStore from '~/stores/TransactionStore.js';
import { formatMoney } from '~/utils/NumberFormatter.js';

import { Bar as BarChart } from 'vue-chartjs';
import CollapsibleCard from '~/components/bootstrap/CollapsibleCard.vue';

const CHART_X_MAX = 1000;
const CHART_X_MIN = -1000;
const ONE_THOUSAND = 1000;
const MONEY_IN_COLOR = '#268c4d80';
const SPENDS_COLOR = '#d9534f80';

export default {
  components: {
    BarChart,
    CollapsibleCard,
  },

  setup() {
    const chart = ref(null);

    const t = I18n.scopedTranslator('views.dashboard.show');
    const transactionStore = useTransactionStore();

    const { statistics } = storeToRefs(transactionStore);

    ChartJS.register(
      BarElement,
      BarController,
      CategoryScale,
      LinearScale,
      Tooltip,
      ChartDataLabels,
      AnnotationPlugin
    );

    const chartData = computed(() => {
      return {
        labels: statistics.value.dailyTotals?.map(total => total.date) || [],
        datasets: [{
          data: statistics.value.dailyTotals?.map(total => total.amount) || [],
          backgroundColor: statistics.value.dailyTotals?.map((total) => {
            return total.amount > 0 ? MONEY_IN_COLOR : SPENDS_COLOR;
          }) || [],
        }],
      };
    });

    const yAxisTickFormatter = (label) => {
      if (Math.abs(label) >= ONE_THOUSAND) {
        return `${formatMoney(label / ONE_THOUSAND, null, false)}k`;
      } else {
        return formatMoney(label, null, false);
      }
    };

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
          align: 'end',
          offset: 0,
          clamp: true,
          formatter: value => formatMoney(value),
          display: 'auto',
        },
        tooltip: {
          callbacks: {
            title: tooltip => dayjs(tooltip[0].label).format('L'),
            label: tooltip => formatMoney(tooltip.raw),
          },
        },
      },
      scales: {
        x: {
          grid: {
            display: false,
          },
          ticks: {
            callback: function(label) {
              return dayjs(this.getLabelForValue(label)).date();
            }
          },
        },
        y: {
          ticks: {
            callback: yAxisTickFormatter,
          },
          min: CHART_X_MIN,
          max: CHART_X_MAX,
        },
      },
    };

    const spendsTriangle = (index) => {
      return {
        type: 'polygon',
        xValue: index,
        yValue: CHART_X_MIN - 80,
        sides: 3,
        radius: 5,
        backgroundColor: SPENDS_COLOR,
        id: 'triangle',
        rotation: 180,
        borderColor: 'transparent',
      }
    };

    const moneyInTriangle = (index) => {
      return {
        type: 'polygon',
        xValue: index,
        yValue: CHART_X_MAX + 80,
        sides: 3,
        radius: 5,
        backgroundColor: MONEY_IN_COLOR,
        id: 'triangle',
        borderColor: 'transparent',
      };
    };

    watch(statistics, async () => {
      await nextTick();

      const chartInstance = chart.value.chart;

      // Reset annotations
      chartInstance.config.options.plugins.annotation = { clip: false, annotations: {} };

      // Draw triangles to indicate data point exceeds chart limits
      chartInstance.data.datasets[0].data.forEach((dataPoint, index) => {
        if (dataPoint > CHART_X_MAX) {
          chartInstance.config.options.plugins.annotation.annotations[`moneyIn_${index}`] = moneyInTriangle(index);
        } else if (dataPoint < CHART_X_MIN) {
          chartInstance.config.options.plugins.annotation.annotations[`spends_${index}`] = spendsTriangle(index);
        }
      });

      chartInstance.update();
    });

    return {
      t,
      chart,
      chartData,
      chartOptions,
    };
  }
};
</script>
