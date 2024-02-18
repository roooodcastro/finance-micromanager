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
      if (!this.speedDialEntries.map(entry => entry.label).includes(config.label)) {
        this.speedDialEntries.push(config);
      }
    },
  },
});
