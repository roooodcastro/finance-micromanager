import { defineStore } from 'pinia';
import dayjs from 'dayjs';

export default defineStore('dateRange', {
  state: () => ({
    type: 'month',
    startDate: dayjs().tz('utc').startOf('month'),
  }),

  getters: {
    nextEnabled: (state) => state.startDate < dayjs().startOf(state.type),
    maxDate: () => dayjs().format('YYYY-MM'),
    endDate: (state) => dayjs(state.startDate).endOf(state.type),
    startMonth: (state) => state.startDate.format('MMMM'),
    startYear: (state) => state.startDate.year(),
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
