<template>
  <select
    v-bind="$attrs"
    class="form-select"
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
import { currencies } from '~/api';

export default {
  setup() {
    let availableCurrencies = ref([]);

    currencies.list().then(response => availableCurrencies.value = response);

    return { availableCurrencies };
  },
};
</script>
