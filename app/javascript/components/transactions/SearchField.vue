<template>
  <div class="input-group flex-grow-0">
    <input
      id="transactionSearch"
      name="transactionSearch"
      class="form-control form-control-sm"
      :placeholder="t('search_label')"
      :value="modelValue ?? $attrs.value"
      @input="handleInput"
    >

    <button class="btn btn-sm btn-secondary">
      <FontAwesomeIcon icon="magnifying-glass" />
    </button>
  </div>
</template>

<script>
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';

import I18n from '~/utils/I18n.js';
import { ref } from 'vue';

const DEBOUNCING_TIMEOUT = 300;

export default {
  components: {
    FontAwesomeIcon,
  },

  props: {
    modelValue: {
      type: String,
      default: null,
    },
  },

  emits: ['update:modelValue', 'input'],

  setup(props, { emit }) {
    const t = I18n.scopedTranslator('views.transactions.filters');

    const debouncingTimeout = ref(null);

    const handleInput = (ev) => {
      if (debouncingTimeout.value) {
        clearTimeout(debouncingTimeout.value);
      }

      debouncingTimeout.value = setTimeout(() => {
        emit('update:modelValue', ev.target.value);
        emit('input', ev.target.value);
      }, DEBOUNCING_TIMEOUT);
    };

    return {
      t,
      handleInput,
    };
  },
};
</script>
