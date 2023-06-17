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
import { storeToRefs } from 'pinia';
import useFlashStore from '~/stores/FlashStore.js';

import CloseButton from '~/components/bootstrap/CloseButton.vue';

export default {
  components: {
    CloseButton,
  },

  setup() {
    const { successMessages, warningMessages, errorMessages } = storeToRefs(useFlashStore());

    return {
      successMessages,
      warningMessages,
      errorMessages,
    };
  }
};
</script>
