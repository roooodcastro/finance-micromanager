<template>
  <select
    v-bind="$attrs"
    class="form-select"
    :value="modelValue ?? $attrs.value"
    @change="handleChange"
  >
    <option />
    <option
      v-for="option in options"
      :key="option.id"
      :value="option.id"
    >
      {{ option.name }}
    </option>
  </select>
</template>

<script>
import { storeToRefs } from 'pinia';

import useWalletStore from '~/stores/WalletStore.js';

export default {
  props: {
    modelValue: {
      type: String,
      default: null,
    },
  },

  emits: ['update:modelValue', 'change'],

  setup(_props, { emit }) {
    const walletStore = useWalletStore();
    const { activeWallets: options } = storeToRefs(walletStore);

    if (!options.value.length) {
      walletStore.fetch();
    }

    const handleChange = (ev) => {
      emit('update:modelValue', ev.target.value);
      emit('change', ev.target.value);
    }

    return {
      options,
      handleChange,
    };
  },
};
</script>
