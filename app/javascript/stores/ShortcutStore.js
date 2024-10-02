import { defineStore } from 'pinia';
import hotkeys from 'hotkeys-js';

export default defineStore('shortcut', {
  state: () => ({
    shortcuts: {},
  }),

  actions: {
    registerShortcut(keys, label, keyLabels, callback) {
      if (!this.shortcuts[keys]) {
        hotkeys(keys, callback);
        this.shortcuts[keys] = { keyLabels, label };
      }
    },
  },
});
