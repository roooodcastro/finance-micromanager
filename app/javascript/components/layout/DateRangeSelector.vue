<template>
  <div
    class="btn-group d-flex bg-white"
    role="group"
  >
    <button
      type="button"
      class="DateRangeSelector__button btn flex-grow-0"
      @click="handlePrev"
    >
      <FontAwesomeIcon icon="chevron-left" />
    </button>

    <button
      type="button"
      class="DateRangeSelector__button btn flex-grow-1 fs-4 d-flex align-items-center justify-content-center"
      @click="handlePickerOpen"
    >
      <input
        ref="monthInput"
        type="month"
        class="d-none"
        :value="startDate.format('YYYY-MM')"
        :max="maxDate"
        @input="handlePickerChange"
      >
      <span>{{ month }}</span>
      <span class="DateRangeSelector__sub-date text-muted ms-2">
        {{ year }}
      </span>
    </button>

    <button
      type="button"
      class="DateRangeSelector__button btn flex-grow-0"
      :disabled="!nextEnabled"
      @click="handleNext"
    >
      <FontAwesomeIcon icon="chevron-right" />
    </button>
  </div>
</template>

<script>
import { ref } from 'vue';
import { storeToRefs } from 'pinia';
import useDateRangeStore from '~/stores/DateRangeStore.js';

import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';

export default {
  components: {
    FontAwesomeIcon,
  },

  emits: ['change'],

  setup(_, { emit }) {
    const monthInput = ref(null);
    const dateRangeStore = useDateRangeStore();
    const { maxDate, startDate, startMonth: month, startYear: year, nextEnabled } = storeToRefs(dateRangeStore);

    const handlePrev = () => {
      dateRangeStore.prev();
      emit('change');
    }
    const handleNext = () => {
      dateRangeStore.next();
      emit('change');
    }
    const handlePickerOpen = () => monthInput.value.showPicker();
    const handlePickerChange = (ev) => {
      dateRangeStore.setStartDate(ev.target.value);
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
  border-color: $border-color-translucent;

  &:hover, &:active, &:focus {
    background-color: $gray-300;
  }
  &:disabled {
    color: $gray-400;
  }
}
</style>
