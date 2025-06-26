<template>
  <BarChart
    ref="chart"
    :data="chartData"
    :options="chartOptions"
  />
</template>

<script>
import { computed, ref, nextTick, watch, onMounted, onUnmounted } from 'vue';
import {
  Chart as ChartJS,
  Tooltip,
  BarElement,
  BarController,
  CategoryScale,
  LinearScale,
  LineElement,
  PointElement,
} from 'chart.js';
import ChartDataLabels from 'chartjs-plugin-datalabels';

import { Bar as BarChart } from 'vue-chartjs';

export default {
  components: {
    BarChart,
  },

  props: {
    datasets: {
      type: Array,
      required: true,
    },
    labels: {
      type: Array,
      required: true,
    },
    datalabelsOptions: {
      type: Object,
      default: () => {},
    },
    tooltipLabelFormatter: {
      type: Function,
      required: true,
    },
    yTicksFormatter: {
      type: Function,
      required: true,
    },
    xScaleOptions: {
      type: Object,
      default: () => {},
    },
    yScaleOptions: {
      type: Object,
      default: () => {},
    },
  },

  setup(props) {
    const chart = ref(null);
    const labelsColor = ref('');
    const gridColor = ref('');

    ChartJS.register(
      BarElement,
      BarController,
      CategoryScale,
      LinearScale,
      LineElement,
      PointElement,
      Tooltip,
      ChartDataLabels,
    );

    const defaultDatalabelsOptions = computed(() => {
      return {
        clamp: true,
        color: labelsColor.value,
        display: 'auto',
        offset: 0,
      };
    });

    const defaultxScaleOptions = computed(() => {
      return {
        stacked: true,
        grid: {
          color: gridColor.value,
        },
        ticks: {
          autoSkipPadding: 0,
          color: labelsColor.value,
          maxRotation: 90,
        },
      };
    });

    const defaultyScaleOptions = computed(() => {
      return {
        grid: {
          color: gridColor.value,
        },
        ticks: {
          callback: props.yTicksFormatter,
          color: labelsColor.value,
        },
      };
    });

    const chartData = computed(() => {
      return {
        labels: props.labels,
        datasets: props.datasets,
      };
    });

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
        barPercentage: 0.9,
        plugins: {
          datalabels: Object.assign(defaultDatalabelsOptions.value, props.datalabelsOptions),
          tooltip: {
            callbacks: {
              label: props.tooltipLabelFormatter,
            },
          },
        },
        scales: {
          x: Object.assign(defaultxScaleOptions.value, props.xScaleOptions),
          y: Object.assign(defaultyScaleOptions.value, props.yScaleOptions),
        },
      };
    });

    watch(chartData, async () => {
      await nextTick();

      const chartInstance = chart.value.chart;

      // Reset annotations, if any
      chartInstance.config.options.plugins.annotation = { clip: false, annotations: {} };

      chartInstance.update();
    });

    const updateColorVariables = () => {
      labelsColor.value = `${getComputedStyle(document.documentElement).getPropertyValue('--bs-body-color')}DD`;
      gridColor.value = `${getComputedStyle(document.documentElement).getPropertyValue('--bs-body-color')}20`;
    }

    onMounted(() => {
      updateColorVariables();

      document.body.addEventListener('themeChanged', () => {
        updateColorVariables();
      });
    });

    onUnmounted(() => {
      document.body.removeEventListener('themeChanged');
    });

    return {
      chart,
      chartData,
      chartOptions,
    };
  },
};
</script>
