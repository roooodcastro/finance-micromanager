import { defineStore } from 'pinia';
import dayjs from 'dayjs';

import { getValueFromJsonCookie, setValueToJsonCookie } from '~/utils/CookieUtils.js';
import { DATE_RANGE_COOKIE_NAME } from '~/utils/Constants.js';

export default defineStore('dateRange', {
  state: () => ({
    type: 'month',
    startDate: dayjs().tz('utc').utc().startOf('month'),
  }),

  getters: {
    nextEnabled: (state) => state.startDate < dayjs().tz('utc').utc().startOf(state.type),
    maxDate: () => dayjs().tz('utc').utc().format('YYYY-MM'),
    endDate: (state) => dayjs(state.startDate).tz('utc').utc().endOf(state.type),
    startMonth: (state) => state.startDate.format('MMMM'),
    startYear: (state) => state.startDate.year(),
    rangeKey: (state) => {
      const startDateKey = state.startDate.format('YYYYMMDD');
      const endDate = dayjs(state.startDate).tz('utc').utc().endOf(state.type);
      const endDateKey = endDate.format('YYYYMMDD');
      return [startDateKey, endDateKey].join('-');
    }
  },

  actions: {
    loadFromCookie() {
      this.type = getValueFromJsonCookie(DATE_RANGE_COOKIE_NAME, 'type') ?? this.type;
      const startDateFromCookie = getValueFromJsonCookie(DATE_RANGE_COOKIE_NAME, 'startDate');
      this.startDate = startDateFromCookie ? dayjs(startDateFromCookie).tz('utc').utc() : this.startDate;
    },
    setStartDate(newDate) {
      this.startDate = dayjs(newDate).tz('utc').utc().startOf('month');
      setValueToJsonCookie(DATE_RANGE_COOKIE_NAME, 'startDate', this.startDate.format());
    },
    setType(newType) {
      this.type = newType;
      setValueToJsonCookie(DATE_RANGE_COOKIE_NAME, 'type', newType);
    },
    next() {
      this.setStartDate(this.startDate.add(1, this.type));
    },

    prev() {
      this.setStartDate(this.startDate.add(-1, this.type));
    }
  },
});
