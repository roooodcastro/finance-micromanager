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
import { computed } from 'vue';
import { storeToRefs } from 'pinia';

import useWalletStore from '~/stores/WalletStore.js';

export default {
  props: {
    wallets: {
      type: Array,
      default: () => [],
    },
    useWalletsFromProps: {
      type: Boolean,
      default: false,
    },
    modelValue: {
      type: String,
      default: null,
    },
  },

  emits: ['update:modelValue', 'change'],

  setup(props, { emit }) {
    const walletStore = useWalletStore();
    const { activeWallets } = storeToRefs(walletStore);
    const options = computed(() => props.useWalletsFromProps ? props.wallets : activeWallets.value);

    if (!props.useWalletsFromProps && !activeWallets.value.length) {
      walletStore.fetchCollection();
    }

    const handleChange = (ev) => {
      emit('update:modelValue', ev.target.value);
      emit('change', ev.target.value);
    };

    return {
      options,
      handleChange,
    };
  },
};
</script>
