import { watch } from 'vue';
import { storeToRefs } from 'pinia';

import useDateRangeStore from '~/stores/DateRangeStore.js';

export function onDateRangeChange(callback) {
  const dateRangeStore = useDateRangeStore();
  const { startDate } = storeToRefs(dateRangeStore);
  watch(startDate, callback);
}
