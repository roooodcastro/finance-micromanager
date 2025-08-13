<template>
  <div
    class="btn-group d-flex"
    role="group"
  >
    <button
      type="button"
      class="DateRangeSelector__button btn btn-outline-primary btn-sm flex-grow-0 py-1 py-lg-2 px-2 px-lg-3"
      @click="handlePrev"
    >
      <FontAwesomeIcon icon="chevron-left" />
    </button>

    <button
      :id="`monthPickerToggle__${$attrs.id}`"
      type="button"
      class="DateRangeSelector__button btn btn-outline-primary btn-sm flex-grow-1 fs-5 d-flex align-items-center justify-content-center py-1 py-lg-2 px-2 px-lg-3"
      data-bs-toggle="dropdown"
      data-bs-auto-close="outside"
      aria-expanded="false"
      @click="handlePickerOpen"
    >
      <input
        ref="monthInput"
        type="month"
        class="d-none"
        :value="startDate.format('YYYY-MM')"
        :max="maxDate"
      >
      {{ month }} {{ year }}
    </button>

    <MonthPickerInput
      id="monthInput"
      :value="startDate.format('YYYY-MM')"
      :max="maxDate"
      :toggle-id="`monthPickerToggle__${$attrs.id}`"
      @change="handlePickerChange"
    />

    <button
      type="button"
      class="DateRangeSelector__button btn btn-outline-primary btn-sm flex-grow-0 py-1 py-lg-2 px-2 px-lg-3"
      :disabled="!nextEnabled"
      @click="handleNext"
    >
      <FontAwesomeIcon icon="chevron-right" />
    </button>
  </div>
</template>

<script>
import { computed, ref } from 'vue';
import { storeToRefs } from 'pinia';
import _ from 'lodash';

import useDateRangeStore from '~/stores/DateRangeStore.js';
import useShortcutStore from '~/stores/ShortcutStore.js';

import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';

import MonthPickerInput from '~/components/forms/MonthPickerInput.vue';

export default {
  components: {
    FontAwesomeIcon,
    MonthPickerInput,
  },

  emits: ['change'],

  setup(_props, { emit }) {
    const shortcutStore = useShortcutStore();
    const dateRangeStore = useDateRangeStore();

    const monthInput = ref(null);
    const { maxDate, startDate, startYear: year, nextEnabled } = storeToRefs(dateRangeStore);

    const month = computed(() => _.upperFirst(startDate.value.format('MMM')));

    const handlePrev = () => {
      dateRangeStore.prev();
      emit('change');
    }
    const handleNext = () => {
      dateRangeStore.next();
      emit('change');
    }

    shortcutStore.registerShortcut('alt+,', 'date_range_prev', ['alt', '<'], handlePrev);
    shortcutStore.registerShortcut('alt+.', 'date_range_next', ['alt', '>'], handleNext);

    const handlePickerOpen = () => monthInput.value.showPicker();
    const handlePickerChange = (newDate) => {
      dateRangeStore.setStartDate(newDate);
      emit('change');
    }

    return {
      startDate,
      maxDate,
      month,
      year,
      nextEnabled,
      handlePrev,
      handleNext,
      handlePickerOpen,
      handlePickerChange,
      monthInput,
    };
  }
};
</script>

<style lang="scss" scoped>
@import '../../stylesheets/variables';

.DateRangeSelector__button {
  text-transform: initial;

  &:disabled {
    color: var(--bs-tertiary-color);
  }
}
</style>
