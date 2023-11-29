import { defineStore } from 'pinia';
import moment from 'moment';

export default defineStore('dateRange', {
  state: () => ({
    type: 'month',
    startDate: moment().startOf('month'),
  }),

  getters: {
    nextEnabled: (state) => state.startDate < moment().startOf(state.type),
    maxDate: () => moment().format('YYYY-MM'),
    endDate: (state) => moment(state.startDate).endOf(state.type),
    startMonth: (state) => state.startDate.format('MMMM'),
    startYear: (state) => state.startDate.year(),
  },

  actions: {
    setFromProps(props) {
      this.startDate = moment(props.startDate);
    },
    setStartDate(newDate) {
      this.startDate = moment(newDate).startOf(this.type);
    },
    setType(newType) {
      this.type = newType;
      this.startDate = this.startDate.startOf(newType);
    },
    next() {
      this.startDate = moment(this.startDate.add(1, this.type).startOf(this.type));
    },

    prev() {
      this.startDate = moment(this.startDate.add(-1, this.type).startOf(this.type));
    }
  },
});
