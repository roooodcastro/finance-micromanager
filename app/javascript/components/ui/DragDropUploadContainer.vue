<template>
  <div
    ref="dropZone"
    class="DrapDropUploadContainer card user-select-none"
  >
    <input
      ref="sourceFileInput"
      type="file"
      :accept="acceptedFileExtensions"
      class="d-none"
      @change="handleFileSelected"
    >

    <div class="card-body text-center">
      <FontAwesomeIcon
        :icon="wrongFormatDragging ? ['far', 'circle-xmark'] : dragging ? ['far', 'circle-check'] : 'cloud-arrow-up'"
        size="xl"
        class="fs-1 mb-4"
        :class="{ 'text-danger': wrongFormatDragging, 'text-success': dragging && !wrongFormatDragging }"
        :beat="dragging"
      />
      <p :class="{ 'fs-2': dragging }">
        <template v-if="dragging">
          <template v-if="wrongFormatDragging">
            {{ t('file_format_not_accepted') }}
          </template>
          <template v-else>
            {{ instructionsTextDragging ?? t('instructions_dragging') }}
          </template>
        </template>
        <template v-else>
          {{ instructionsText ?? t('instructions') }}
          <template v-if="acceptedFileExtensions">
            {{ t('accepted_file_formats', { accepted_file_formats: acceptedFileExtensions }) }}
          </template>
        </template>
      </p>
      <p :class="{ 'opacity-0': dragging }">
        {{ t('or') }}
      </p>
      <button
        class="btn btn-primary btn-sm"
        :class="{ 'opacity-0': dragging }"
        @click="sourceFileInput.click()"
      >
        {{ t('browse_button') }}
      </button>
    </div>
  </div>
</template>

<script>
import {computed, onMounted, onUnmounted, ref} from 'vue';
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';

import I18n from '~/utils/I18n.js';
import { fileExtToMimeType } from '~/utils/FileUtils.js';
import useNotificationStore from '~/stores/NotificationStore.js';

export default {
  components: {
    FontAwesomeIcon,
  },

  props: {
    instructionsText: {
      type: String,
      default: null,
    },
    instructionsTextDragging: {
      type: String,
      default: null,
    },
    acceptedFileExtensions: {
      type: String,
      default: null,
    },
  },

  emits: ['change'],

  setup(props, { emit }) {
    const t = I18n.scopedTranslator('views.components.drag_drop_upload_container');
    const dropZone = ref(null);
    const sourceFileInput = ref(null);
    const dragLeaveTimeout = ref(null);
    const dragging = ref(false);
    const wrongFormatDragging = ref(false);

    const notificationStore = useNotificationStore();

    const acceptedMimeTypes = computed(() => props.acceptedFileExtensions.split(',').map(ext => fileExtToMimeType(ext)));

    onMounted(() => {
      window.addEventListener('dragover', preventDefault);
      window.addEventListener('drop', preventDefault);
      dropZone.value.addEventListener('drop', handleFileDrop);
      dropZone.value.addEventListener('dragover', handleDragEnter);
      dropZone.value.addEventListener('dragleave', handleDragLeave);
    });

    onUnmounted(() => {
      window.removeEventListener('dragover', preventDefault);
      window.removeEventListener('drop', preventDefault);
      if (dropZone.value) {
        dropZone.value.removeEventListener('drop', handleFileDrop);
        dropZone.value.removeEventListener('dragover', handleDragEnter);
        dropZone.value.removeEventListener('dragleave', handleDragLeave);
      }
    })

    const preventDefault = ev => ev.preventDefault();
    const isSupportedFile = file => acceptedMimeTypes.value.includes(file.type);

    const handleFileDrop = (ev) => {
      ev.preventDefault();
      handleDragLeave();

      const file = ev.dataTransfer.items[0].getAsFile();
      const nameParts = file.name.split('.');
      const extension = nameParts[nameParts.length - 1];
      const acceptedExtensions = props.acceptedFileExtensions.split(',').map(ext => ext.slice(1));
      if (acceptedExtensions.includes(extension)) {
        emit('change', file);
      } else {
        notificationStore.notify(t('file_format_not_accepted'), 'danger');
      }
    };

    const handleDragEnter = (ev) => {
      clearTimeout(dragLeaveTimeout.value);
      dropZone.value.classList.add('dragging');
      dropZone.value.classList.add('focus-ring');
      dragging.value = true;
      wrongFormatDragging.value = !isSupportedFile(ev.dataTransfer.items[0]);
    };

    const handleDragLeave = () => {
      dragLeaveTimeout.value = setTimeout(() => {
        dropZone.value.classList.remove('dragging');
        dropZone.value.classList.remove('focus-ring');
        dragging.value = false;
        wrongFormatDragging.value = false;
      }, 100);
    };

    const handleFileSelected = (ev) => {
      const file = ev.target.files[0];
      emit('change', file);
    }

    return {
      t,
      dropZone,
      dragging,
      wrongFormatDragging,
      sourceFileInput,
      handleFileSelected,
    };
  },
};
</script>

<style lang="scss" scoped>
.DrapDropUploadContainer {
  height: 14rem;
}

.DrapDropUploadContainer, .DrapDropUploadContainer * {
  transition: all 0.15s linear;
}

.DrapDropUploadContainer.dragging {
}
</style>
