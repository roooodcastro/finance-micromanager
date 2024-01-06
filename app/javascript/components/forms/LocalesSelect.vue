<template>
  <select
    v-bind="$attrs"
    class="form-select"
    :value="modelValue ?? $attrs.value"
    @change="handleChange"
  >
    <option
      v-for="locale in locales"
      :key="locale.locale"
      :value="locale.locale"
    >
      {{ locale.name }}
    </option>
  </select>
</template>

<script>
import { storeToRefs } from 'pinia';

import useLocaleStore from '~/stores/LocaleStore.js';

export default {
  props: {
    modelValue: {
      type: String,
      default: null,
    },
  },

  emits: ['update:modelValue', 'change'],

  setup(_props, { emit }) {
    const localeStore = useLocaleStore();
    const { locales } = storeToRefs(localeStore);

    const handleChange = (ev) => {
      emit('update:modelValue', ev.target.value);
      emit('change', ev.target.value);
    };

    return {
      locales,
      handleChange,
    };
  },
};
</script>
