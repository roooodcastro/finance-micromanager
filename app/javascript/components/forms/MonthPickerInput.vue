<template>
  <div>
    <input
      :id="id"
      ref="monthInput"
      :name="name"
      type="month"
      class="d-none"
      :value="modelValue ?? $attrs.value"
      :min="min"
      :max="max"
    >
    <div
      ref="dropdownEl"
      class="MonthPickerInput dropdown-menu dropdown-menu-end p-0"
      :aria-labelledby="toggleId"
    >
      <div class="p-2">
        <div class="MonthPickerInput__yearRow text-center border-bottom mb-2 pb-2">
          <button
            type="button"
            class="btn btn-sm"
            :class="{ 'invisible': hidePrevChevron }"
            @click="handlePrevYear"
          >
            <FontAwesomeIcon icon="chevron-left" />
          </button>

          <button
            type="button"
            class="btn btn-sm"
            @click="handleEnterYearMode"
          >
            <template v-if="mode === MODE_MONTH">
              {{ selectedYear }}
            </template>
            <template v-else>
              {{ selectedDecade }} - {{ selectedDecade + 10 }}
            </template>
          </button>

          <button
            type="button"
            class="btn btn-sm"
            :class="{ 'invisible': hideNextChevron }"
            @click="handleNextYear"
          >
            <FontAwesomeIcon icon="chevron-right" />
          </button>
        </div>
        <div class="MonthPickerInput__monthRow">
          <template v-if="mode === MODE_MONTH">
            <a
              v-for="(month, index) in monthNames"
              :key="month"
              href="#"
              class="MonthPickerInput__option btn border-0 text-body"
              :class="{
                'btn-primary': index === selectedMonth && selectedDate.year() === selectedYear,
                'invisible': (selectedYear > maxYear || (selectedYear >= maxYear && index > maxMonth)) || (selectedYear < minYear || (selectedYear <= minYear && index < minMonth))
              }"
              @click="handleMonthSelected(index)"
            >
              {{ month }}
            </a>
          </template>
          <template v-else>
            <a
              v-for="(_, index) in 10"
              :key="index"
              href="#"
              class="MonthPickerInput__option btn border-0 text-body"
              :class="{
                'btn-primary': selectedDate.year() === (selectedDecade + index),
                'invisible': selectedDecade + index > maxYear
              }"
              @click="handleYearSelected(selectedDecade + index)"
            >
              {{ selectedDecade + index }}
            </a>
          </template>
        </div>

        <div class="MonthPickerInput__todayRow d-flex justify-content-end border-top mt-2 pt-2 text-right">
          <a
            href="#"
            class="btn btn-sm btn-outline-primary"
            @click="handleTodayClick"
          >
            {{ t('today_label') }}
          </a>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, computed, onMounted, onUnmounted } from 'vue';
import dayjs from 'dayjs';
import _ from 'lodash';
import { Dropdown as BootstrapDropdown } from 'bootstrap';

import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';

import I18n from '~/utils/I18n.js';

const MODE_YEAR = 'year';
const MODE_MONTH = 'month';

export default {
  components: { FontAwesomeIcon },

  props: {
    id: {
      type: String,
      required: true,
    },
    name: {
      type: String,
      default: null,
    },
    modelValue: {
      type: String,
      default: null,
    },
    toggleId: {
      type: String,
      required: true,
    },
    min: {
      type: String,
      default: null,
    },
    max: {
      type: String,
      default: null,
    },
  },

  emits: ['update:modelValue', 'change'],

  setup(props, { attrs, emit }) {
    const t = I18n.scopedTranslator('views.components.layout.month_picker_input');

    const dropdownEl = ref(null);
    const bootstrapDropdown = ref(null);
    const mode = ref('month');
    const selectedYear = ref('');
    const selectedDecade = ref('');
    const minMonth = ref('');
    const minYear = ref('');
    const maxMonth = ref('');
    const maxYear = ref('');
    const locale = I18n.getLocale();
    const monthFormatter = new Intl.DateTimeFormat(locale, { month: 'short' }).format;
    const monthNames = [...Array(12).keys()].map(month => _.upperFirst(monthFormatter(new Date(Date.UTC(2000, month)))));

    const selectedDate = computed(() => dayjs(props.modelValue ?? attrs.value));
    const selectedMonth = computed(() => selectedDate.value.month());
    selectedYear.value = selectedDate.value.year();

    if (props.max) {
      maxYear.value = parseInt(props.max.split('-')[0]);
      maxMonth.value = parseInt(props.max.split('-')[1]) - 1;
    }

    if (props.min) {
      minYear.value = parseInt(props.min.split('-')[0]);
      minMonth.value = parseInt(props.min.split('-')[1]) - 1;
    }

    const hidePrevChevron = computed(() => {
      if (!props.min) {
        return false;
      }
      if (mode.value === MODE_MONTH) {
        return selectedYear.value <= minYear.value;
      } else {
        return selectedDecade.value <= minYear.value;
      }
    });

    const hideNextChevron = computed(() => {
      if (!props.max) {
        return false;
      }
      if (mode.value === MODE_MONTH) {
        return selectedYear.value >= maxYear.value;
      } else {
        return selectedDecade.value + 10 >= maxYear.value;
      }
    });

    const handleMonthSelected = (monthIndex) => {
      const newDate = dayjs(`${selectedYear.value}-${(monthIndex + 1).toString().padStart(2, '0')}-02`).tz('utc').utc().startOf('month');
      bootstrapDropdown.value.hide();
      if (selectedYear.value !== newDate.year() || selectedMonth.value !== newDate.month()) {
        emit('update:modelValue', newDate);
        emit('change', newDate);
      }
    };

    const handleYearSelected = (newYear) => {
      selectedYear.value = newYear;
      mode.value = MODE_MONTH;
    };

    const handleEnterYearMode = () => mode.value = MODE_YEAR;
    const handlePrevYear = () => {
      if (mode.value === MODE_MONTH) {
        selectedYear.value -= 1;
        selectedDecade.value = Math.floor(selectedYear.value / 10) * 10;
      } else {
        selectedDecade.value -= 10;
      }
    };
    const handleNextYear = () => {
      if (mode.value === MODE_MONTH) {
        selectedYear.value += 1;
        selectedDecade.value = Math.floor(selectedYear.value / 10) * 10;
      } else {
        selectedDecade.value += 10;
      }
    }

    const handleDropdownShow = (ev) => {
      if (ev.target.id === props.toggleId) {
        selectedYear.value = selectedDate.value.year();
        selectedDecade.value = Math.floor(selectedYear.value / 10) * 10;
        mode.value = MODE_MONTH;
      }
    };

    const handleTodayClick = () => {
      const today = dayjs();
      selectedYear.value = today.year();
      handleMonthSelected(today.month());
    };

    onMounted(() => {
      bootstrapDropdown.value = BootstrapDropdown.getOrCreateInstance(document.getElementById(props.toggleId));
      document.getElementById(props.toggleId).addEventListener('show.bs.dropdown', handleDropdownShow);
    });

    onUnmounted(() => {
      bootstrapDropdown.value.dispose();
      document.getElementById(props.toggleId).removeEventListener('show.bs.dropdown', handleDropdownShow);
    });

    return {
      t,
      dropdownEl,
      mode,
      selectedDate,
      selectedMonth,
      selectedYear,
      selectedDecade,
      monthNames,
      minMonth,
      minYear,
      maxMonth,
      maxYear,
      hidePrevChevron,
      hideNextChevron,
      handlePrevYear,
      handleNextYear,
      handleEnterYearMode,
      handleYearSelected,
      handleMonthSelected,
      handleTodayClick,
      MODE_MONTH,
      MODE_YEAR,
    };
  },
};
</script>

<style lang="scss" scoped>
.MonthPickerInput__yearRow {
  button:hover {
    background-color: var(--bs-secondary-bg);
  }
}

.MonthPickerInput__monthRow {
  display: grid;
  grid-template-columns: auto auto auto;
}

.MonthPickerInput__todayRow {
  .btn {
    text-transform: none;
  }
}

.MonthPickerInput__option {
  cursor: pointer;
  text-transform: none;

  &:hover {
    background-color: var(--bs-secondary-bg);
  }
}
</style>
