import { defineStore } from 'pinia'

export default defineStore('floatingActionButton', {
  state: () => ({
    speedDialEntries: [],
  }),
  actions: {
    /* Config should be in the format:
     *
     * { label: String, icon: [String, Array], callback: Function, href: String }
     */
    registerSpeedDialEntry(config) {
      this.speedDialEntries.push(config);
    },
  },
});
