import { defineStore } from 'pinia';
import dayjs from 'dayjs';

export default defineStore('dateRange', {
  state: () => ({
    type: 'month',
    startDate: dayjs().tz('utc').startOf('month'),
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
    setFromProps(props) {
      this.startDate = dayjs.tz(props.startDate, 'utc');
    },
    setStartDate(newDate) {
      this.startDate = dayjs.tz(newDate, 'utc').startOf(this.type);
    },
    setType(newType) {
      this.type = newType;
      this.startDate = this.startDate.startOf(newType);
    },
    next() {
      this.startDate = this.startDate.add(1, this.type);
    },

    prev() {
      this.startDate = this.startDate.add(-1, this.type);
    }
  },
});
