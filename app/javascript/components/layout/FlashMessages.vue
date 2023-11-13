<template>
  <div>
    <div
      v-for="(message, index) in successMessages"
      :key="`success_${index}`"
      class="alert alert-success alert-dismissible fade show"
    >
      {{ message }}
      <CloseButton />
    </div>

    <div
      v-for="(message, index) in warningMessages"
      :key="`warning_${index}`"
      class="alert alert-warning alert-dismissible fade show"
    >
      <strong>Warning:</strong>
      {{ message }}
      <CloseButton />
    </div>

    <div
      v-for="(message, index) in errorMessages"
      :key="`error_${index}`"
      class="alert alert-danger alert-dismissible fade show"
    >
      <strong>Error:</strong>
      {{ message }}
      <CloseButton />
    </div>
  </div>
</template>

<script>
import { onMounted } from 'vue';
import { storeToRefs } from 'pinia';
import useFlashStore from '~/stores/FlashStore.js';
import { Alert } from 'bootstrap';

import CloseButton from '~/components/bootstrap/CloseButton.vue';

const FLASH_DISMISS_MILLISECONDS = 10_000;

export default {
  components: {
    CloseButton,
  },

  setup() {
    const { successMessages, warningMessages, errorMessages } = storeToRefs(useFlashStore());

    onMounted(() => {
      setTimeout(() => {
        document.querySelectorAll('.alert').forEach((alertElement) => {
          new Alert(alertElement).close();
        });
      }, FLASH_DISMISS_MILLISECONDS);
    });

    return {
      successMessages,
      warningMessages,
      errorMessages,
    };
  }
};
</script>
