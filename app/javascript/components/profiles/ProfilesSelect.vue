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
      :key="option.value"
      :value="option.value"
    >
      {{ option.label }}
    </option>
  </select>
</template>

<script>
import { storeToRefs } from 'pinia';

import useProfileStore from '~/stores/ProfileStore.js';

export default {
  props: {
    modelValue: {
      type: String,
      default: null,
    },
  },

  emits: ['update:modelValue'],

  setup() {
    const profileStore = useProfileStore();
    const { profilesForSelect: options } = storeToRefs(profileStore);

    return { options };
  },
};
</script>
