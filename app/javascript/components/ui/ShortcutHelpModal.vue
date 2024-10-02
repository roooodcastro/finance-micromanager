<template>
  <div
    :id="SHORTCUTS_HELP_MODAL_ID"
    class="modal"
    tabindex="-1"
  >
    <div class="modal-dialog">
      <div class="modal-content">
        <div class="modal-header">
          <h5 class="modal-title">
            {{ t('title') }}
          </h5>
        </div>
        <div class="modal-body">
          <ul class="list-group">
            <li
              v-for="(shortcut, keys) in shortcuts"
              :key="keys"
              class="list-group-item d-flex justify-content-between align-items-center"
            >
              <span>{{ t(shortcut.label) }}</span>
              <span class="d-flex align-items-center gap-2 fs-4 font-monospace">
                <span
                  v-for="key_label in shortcut.keyLabels"
                  :key="`${keys}_${key_label}`"
                  class="badge bg-dark"
                >
                  {{ key_label }}
                </span>
              </span>
            </li>
          </ul>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { onMounted } from 'vue';
import { storeToRefs } from 'pinia';

import I18n from '~/utils/I18n.js';
import { SHORTCUTS_HELP_MODAL_ID } from '~/utils/Constants.js';
import useModalStore from '~/stores/ModalStore.js';
import useShortcutStore from '~/stores/ShortcutStore.js';

export default {
  setup() {
    const t = I18n.scopedTranslator('views.layout.modals.shortcut_help');

    const modalStore = useModalStore();
    const shortcutStore = useShortcutStore();

    const { shortcuts } = storeToRefs(shortcutStore);

    onMounted(() => modalStore.registerModal(SHORTCUTS_HELP_MODAL_ID));

    return {
      t,
      shortcuts,
      SHORTCUTS_HELP_MODAL_ID,
    }
  }
};
</script>
