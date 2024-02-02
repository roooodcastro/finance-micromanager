<template>
  <select
    v-bind="$attrs"
    class="form-select"
    :value="modelValue ?? $attrs.value"
    @change="handleChange"
  >
    <option />
    <option
      v-for="currency in availableCurrencies"
      :key="currency.id"
      :value="currency.id"
    >
      {{ currency.isoCode }} - {{ currency.name }}
    </option>
  </select>
</template>

<script>
import { ref } from 'vue';
import { currencies } from '~/api/all.js';

export default {
  props: {
    modelValue: {
      type: String,
      default: null,
    },
  },

  emits: ['update:modelValue', 'change'],

  setup(_, { emit }) {
    let availableCurrencies = ref([]);

    currencies.index().then(response => availableCurrencies.value = response);

    const handleChange = (ev) => {
      emit('update:modelValue', ev.target.value);
      emit('change', ev.target.value);
    };

    return {
      availableCurrencies,
      handleChange,
    };
  },
};
</script>
