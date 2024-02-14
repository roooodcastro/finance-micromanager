<template>
  <div>
    <CollapsibleCard
      id="dashboard_show_day_chart"
      :loading="loading"
      :title="t('title')"
      header-class="d-flex align-items-center justify-content-between"
      no-body
    >
      <template v-slot:header>
        <DropdownMenu
          toggle-icon="gear"
          :toggle-label="t('options_aria_label')"
        >
          <DropdownMenuItem
            :label="t('display_options_label')"
            icon="magnifying-glass-chart"
            @click="handleDisplayOptionsClick"
          />
        </DropdownMenu>
      </template>
      <template v-slot:default>
        <BarChart
          ref="chart"
          :data="chartData"
          :options="chartOptions"
          class="DailyTotalsChart py-2"
        />
      </template>
    </CollapsibleCard>

    <DailyTotalsChartModeModal @change="handleModeChange" />
  </div>
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
import useModalStore from '~/stores/ModalStore.js';
import { formatMoney } from '~/utils/NumberFormatter.js';
import { isMediaBreakpointDown, isMediaBreakpointUp } from '~/utils/ResponsivenessUtils.js';
import { DAILY_TOTALS_CHART_MODE_MODAL_ID, DISPLAY_OPTIONS_COOKIE_NAME } from '~/utils/Constants.js';
import { getValueFromJsonCookie } from '~/utils/CookieUtils.js';

import { Bar as BarChart } from 'vue-chartjs';
import CollapsibleCard from '~/components/bootstrap/CollapsibleCard.vue';
import DropdownMenu from '~/components/ui/DropdownMenu.vue';
import DropdownMenuItem from '~/components/ui/DropdownMenuItem.vue';
import DailyTotalsChartModeModal from '~/components/statistics/DailyTotalsChartModeModal.vue';

const CHART_X_MAX = 1000;
const CHART_X_MIN = -1000;
const MONEY_IN_COLOR = '#268c4d80';
const SPENDS_COLOR = '#d9534f80';

export default {
  components: {
    BarChart,
    CollapsibleCard,
    DailyTotalsChartModeModal,
    DropdownMenu,
    DropdownMenuItem,
  },

  setup() {
    const chart = ref(null);

    const t = I18n.scopedTranslator('views.statistics.daily_totals_chart');
    const transactionStore = useTransactionStore();

    const { statistics, loading } = storeToRefs(transactionStore);

    const chartMode = ref(getValueFromJsonCookie(DISPLAY_OPTIONS_COOKIE_NAME, 'dailyTotalsChartMode') || 'both');

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
      let datasets = [];

      const onlySpendsDataset = {
        data: statistics.value.dailyTotals?.map(total => total.spends * -1) || [],
        backgroundColor: SPENDS_COLOR,
      };

      const spendsDataset = {
        data: statistics.value.dailyTotals?.map(total => total.spends) || [],
        backgroundColor: SPENDS_COLOR,
      };

      const incomeDataset = {
        data: statistics.value.dailyTotals?.map(total => total.income) || [],
        backgroundColor: MONEY_IN_COLOR,
      };

      if (chartMode.value === 'combined') {
        datasets = [{
          data: statistics.value.dailyTotals?.map(total => total.spends + total.income) || [],
          backgroundColor: statistics.value.dailyTotals?.map((total) => {
            return total.income + total.spends > 0 ? MONEY_IN_COLOR : SPENDS_COLOR;
          }) || [],
        }];
      } else if (chartMode.value === 'spends') {
        datasets = [onlySpendsDataset];
      } else if (chartMode.value === 'income') {
        datasets = [incomeDataset];
      } else if (chartMode.value === 'both') {
        datasets = [spendsDataset, incomeDataset];
      }
      return {
        labels: statistics.value.dailyTotals?.map(total => total.date) || [],
        datasets,
      };
    });

    const xAxisMinRotation = isMediaBreakpointDown('sm') ? 90 : 0;

    const chartOptions = computed(() => {
      return {
        animation: {
          duration: 200,
        },
        maintainAspectRatio: false,
        layout: {
          padding: 0,
        },
        categoryPercentage: 1.0,
        barPercentage: 1.0,
        plugins: {
          datalabels: {
            offset: 0,
            clamp: true,
            formatter: value => value.toFixed(),
            display: isMediaBreakpointUp('lg') ? 'auto' : false,
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
            stacked: true,
            display: isMediaBreakpointUp('md'),
            grid: {
              color: '#00000010',
            },
            ticks: {
              callback: function(label) {
                return dayjs(this.getLabelForValue(label)).date();
              },
              autoSkipPadding: 0,
              maxRotation: 90,
              minRotation: xAxisMinRotation,
            },
          },
          y: {
            ticks: {
              callback: label => formatMoney(label, null, false),
            },
            min: ['income', 'spends'].includes(chartMode.value) ? 0 : CHART_X_MIN,
            max: CHART_X_MAX,
          },
        },
      };
    });

    const spendsTriangle = (config, index) => {
      const max = config.options.scales.y.max;
      const min = config.options.scales.y.min;

      return {
        type: 'polygon',
        xValue: index,
        yValue: min - ((max - min) / 25),
        sides: 3,
        radius: 5,
        backgroundColor: SPENDS_COLOR,
        id: 'triangle',
        rotation: 180,
        borderColor: 'transparent',
      }
    };

    const moneyInTriangle = (config, index) => {
      const max = config.options.scales.y.max;
      const min = config.options.scales.y.min;

      return {
        type: 'polygon',
        xValue: index,
        yValue: max + ((max - min) / 25),
        sides: 3,
        radius: 5,
        backgroundColor: chartMode.value === 'spends' ? SPENDS_COLOR : MONEY_IN_COLOR,
        id: 'triangle',
        borderColor: 'transparent',
      };
    };

    watch(chartData, async () => {
      await nextTick();

      const chartInstance = chart.value.chart;

      // Reset annotations
      chartInstance.config.options.plugins.annotation = { clip: false, annotations: {} };

      // Draw triangles to indicate data point exceeds chart limits
      chartInstance.data.datasets.forEach((dataset) => {
        dataset.data.forEach((dataPoint, index) => {
          if (dataPoint > CHART_X_MAX) {
            chartInstance.config.options.plugins.annotation.annotations[`moneyIn_${index}`] = moneyInTriangle(chartInstance.config, index);
          } else if (dataPoint < CHART_X_MIN) {
            chartInstance.config.options.plugins.annotation.annotations[`spends_${index}`] = spendsTriangle(chartInstance.config, index);
          }
        });
      });

      chartInstance.update();
    });

    const handleDisplayOptionsClick = () => {
      const modalStore = useModalStore();
      modalStore.show(DAILY_TOTALS_CHART_MODE_MODAL_ID);
    };

    const handleModeChange = (newMode) => {
      chartMode.value = newMode;
    };

    return {
      t,
      loading,
      chart,
      chartData,
      chartOptions,
      handleModeChange,
      handleDisplayOptionsClick,
    };
  }
};
</script>

<style lang="scss" scoped>
.DailyTotalsChart {
  height: 15rem;
}
</style>
