import { defineStore } from 'pinia';

import useShortcutStore from '~/stores/ShortcutStore.js';

export default defineStore('floatingActionButton', {
  state: () => ({
    speedDialEntries: [],
  }),
  actions: {
    /* Config should be in the format:
     *
     * { label: String, icon: [String, Array], callback: Function, href: String, shortcut: { keys: String, keyLabels: Array} }
     */
    registerSpeedDialEntry(config) {
      if (!this.speedDialEntries.map(entry => entry.label).includes(config.label)) {
        this.speedDialEntries.push(config);
        if (config.shortcut) {
          const shortcutStore = useShortcutStore();
          shortcutStore.registerShortcut(config.shortcut.keys, config.label, config.shortcut.keyLabels, config.callback);
        }
      }
    },
  },
});
