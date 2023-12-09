<template>
  <select
    v-bind="$attrs"
    class="form-select"
    :value="modelValue ?? $attrs.value"
    @change="$emit('update:modelValue', $event.target.value)"
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

  emits: ['update:modelValue'],

  setup() {
    const walletStore = useWalletStore();
    const { wallets: options } = storeToRefs(walletStore);

    if (!options.length) {
      walletStore.fetch();
    }

    return { options };
  },
};
</script>
