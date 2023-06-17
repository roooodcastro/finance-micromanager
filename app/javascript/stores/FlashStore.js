import { defineStore } from 'pinia'

export default defineStore('flash', {
  state: () => ({
    successMessages: [],
    warningMessages: [],
    errorMessages: [],
  }),

  actions: {
    setMessages(flashMessages) {
      this.successMessages = ([flashMessages?.success] || []).concat([flashMessages?.notice] || []).flat().filter(Boolean);
      this.warningMessages = ([flashMessages?.warning] || []).flat().filter(Boolean);
      this.errorMessages = ([flashMessages?.error] || []).concat([flashMessages?.alert] || []).flat().filter(Boolean);
    },
  },
});
