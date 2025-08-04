<template>
  <div>
    <h4 class="card-title m-0 d-none d-md-block">
      {{ t('title') }}
    </h4>

    <div class="d-flex justify-content-end">
      <a
        href="#"
        class="btn btn-sm btn-outline-secondary py-1"
        @click="handleDisplayOptionsClick"
      >
        <FontAwesomeIcon icon="gear" />
        {{ t('display_options_label') }}
      </a>
    </div>

    <BarChart
      :labels="chartLabels"
      :datasets="chartDatasets"
      :datalabels-options="datalabelsOptions"
      :tooltip-label-formatter="tooltipLabelFormatter"
      :tooltip-title-formatter="tooltipTitleFormatter"
      :x-scale-options="xScaleOptions"
      :y-scale-options="yScaleOptions"
      :chart-update-callback="updateAnnotations"
      class="DailyTotalsChart py-2"
    />

    <DailyTotalsChartModeModal @change="handleModeChange" />
  </div>
</template>

<script>
import { computed, ref, onMounted, onUnmounted } from 'vue';
import { storeToRefs } from 'pinia';
import dayjs from 'dayjs';
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';

import I18n from '~/utils/I18n.js';
import useTransactionStore from '~/stores/TransactionStore.js';
import useModalStore from '~/stores/ModalStore.js';
import { formatMoney } from '~/utils/NumberFormatter.js';
import { isMediaBreakpointDown, isMediaBreakpointUp } from '~/utils/ResponsivenessUtils.js';
import { DAILY_TOTALS_CHART_MODE_MODAL_ID, DISPLAY_OPTIONS_COOKIE_NAME } from '~/utils/Constants.js';
import { getValueFromJsonCookie } from '~/utils/CookieUtils.js';

import BarChart from '~/components/ui/BarChart.vue';
import DailyTotalsChartModeModal from '~/components/statistics/DailyTotalsChartModeModal.vue';

const CHART_Y_MAX = 1000;
const CHART_Y_MIN = -1000;
const MONEY_IN_COLOR = '#268c4d80';
const SPENDS_COLOR = '#d9534f80';

export default {
  components: {
    BarChart,
    DailyTotalsChartModeModal,
    FontAwesomeIcon,
  },

  setup() {
    const t = I18n.scopedTranslator('views.statistics.daily_totals_chart');

    const isMediaBreakpointLgOrUpper = ref('');
    const isMediaBreakpointSmOrLower = ref('');
    const textCreditColor = ref('');
    const textDebitColor = ref('');

    const transactionStore = useTransactionStore();

    const { statistics, loading } = storeToRefs(transactionStore);

    const chartMode = ref(getValueFromJsonCookie(DISPLAY_OPTIONS_COOKIE_NAME, 'dailyTotalsChartMode') || 'both');

    const dailyTotalsUntilToday = computed(() => {
      const daysWithData = statistics.value.dailyTotals?.filter(total => total.spends !== 0 || total.income !== 0) ?? [];
      const maxDateWithData = daysWithData.map(total => total.date).at(-1);
      const today = dayjs().tz('utc').utc();
      const maxDate = maxDateWithData && dayjs.tz(maxDateWithData, 'utc') > today ? dayjs.tz(maxDateWithData, 'utc') : today;
      return statistics.value.dailyTotals?.filter(total => dayjs.tz(total.date, 'utc') <= maxDate) || [];
    });

    const chartLabels = computed(() => statistics.value.dailyTotals?.map(total => total.date) || []);

    const chartDatasets = computed(() => {
      let datasets = [];

      const onlySpendsDataset = {
        data: dailyTotalsUntilToday.value.map(total => total.spends * -1) || [],
        backgroundColor: SPENDS_COLOR,
      };

      const spendsDataset = {
        data: dailyTotalsUntilToday.value.map(total => total.spends) || [],
        backgroundColor: SPENDS_COLOR,
      };

      const incomeDataset = {
        data: dailyTotalsUntilToday.value.map(total => total.income) || [],
        backgroundColor: MONEY_IN_COLOR,
      };

      if (chartMode.value === 'combined') {
        datasets = [{
          data: dailyTotalsUntilToday.value.map(total => total.spends + total.income) || [],
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
      return datasets;
    });

    const dataMaxValue = computed(() => Math.max(...chartDatasets.value.map(dataset => Math.max(...dataset.data))));
    const dataMinValue = computed(() => Math.min(...chartDatasets.value.map(dataset => Math.min(...dataset.data))));
    const yAxisMinValue = computed(() => Math.max(dataMinValue.value, CHART_Y_MIN));
    const yAxisMaxValue = computed(() => Math.min(dataMaxValue.value, CHART_Y_MAX));

    const datalabelsOptions = computed(() => {
      return {
        formatter: value => value.toFixed(),
        display: isMediaBreakpointUp('lg') ? 'auto' : false,
      };
    });

    const tooltipLabelFormatter = tooltip => formatMoney(tooltip.raw);
    const tooltipTitleFormatter = tooltip => dayjs(tooltip[0].label).format('L');

    const xScaleOptions = computed(() => {
      return {
        stacked: true,
        display: !isMediaBreakpointSmOrLower.value,
        grid: {
          color: '#00000010',
        },
        ticks: {
          callback: function(label) {
            return dayjs(this.getLabelForValue(label)).date();
          },
          autoSkipPadding: 0,
          maxRotation: 90,
          minRotation: isMediaBreakpointSmOrLower.value ? 90 : 0,
        },
      };
    });

    const yScaleOptions = computed(() => {
      return {
        ticks: { display: false },
        min: ['income', 'spends'].includes(chartMode.value) ? 0 : yAxisMinValue.value,
        max: yAxisMaxValue.value,
      };
    });

    const updateColorVariables = () => {
      textCreditColor.value = getComputedStyle(document.documentElement).getPropertyValue('--chart-credit-color');
      textDebitColor.value = getComputedStyle(document.documentElement).getPropertyValue('--chart-debit-color');
    };

    const handleResize = () => {
      isMediaBreakpointLgOrUpper.value = isMediaBreakpointUp('lg');
      isMediaBreakpointSmOrLower.value = isMediaBreakpointDown('sm');
    };

    onMounted(() => {
      updateColorVariables();
      isMediaBreakpointLgOrUpper.value = isMediaBreakpointUp('lg');
      isMediaBreakpointSmOrLower.value = isMediaBreakpointDown('sm');

      document.body.addEventListener('themeChanged', updateColorVariables);

      window.addEventListener('resize', handleResize);
    });

    onUnmounted(() => {
      document.body.removeEventListener('themeChanged', updateColorVariables);
      document.body.removeEventListener('resize', handleResize);

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

    const updateAnnotations = (chartInstance) => {
      // Draw triangles to indicate data point exceeds chart limits
      chartInstance.data.datasets.forEach((dataset) => {
        dataset.data.forEach((dataPoint, index) => {
          if (dataPoint > CHART_Y_MAX) {
            chartInstance.config.options.plugins.annotation.annotations[`moneyIn_${index}`] = moneyInTriangle(chartInstance.config, index);
          } else if (dataPoint < CHART_Y_MIN) {
            chartInstance.config.options.plugins.annotation.annotations[`spends_${index}`] = spendsTriangle(chartInstance.config, index);
          }
        });
      });
    };

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
      handleModeChange,
      chartLabels,
      chartDatasets,
      datalabelsOptions,
      tooltipLabelFormatter,
      tooltipTitleFormatter,
      xScaleOptions,
      yScaleOptions,
      updateAnnotations,
      handleDisplayOptionsClick,
    };
  }
};
</script>

<style lang="scss" scoped>
@import '../../stylesheets/variables';

@include media-breakpoint-down(md) {
  .card {
    border-radius: 0 !important;
  }
}

.DailyTotalsChart {
  height: 15rem;
}
</style>
