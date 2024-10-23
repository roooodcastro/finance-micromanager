<template>
  <div class="input-group flex-grow-0 w-auto">
    <input
      v-bind="$attrs"
      class="form-control form-control-sm bg-white"
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

export default {
  components: {
    FontAwesomeIcon,
  },

  inheritAttrs: false,

  props: {
    modelValue: {
      type: String,
      default: null,
    },
    debounceTimeout: {
      type: Number,
      default: 300,
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
      }, props.debounceTimeout);
    };

    return {
      t,
      handleInput,
    };
  },
};
</script>
