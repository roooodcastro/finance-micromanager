<template>
  <select
    v-bind="$attrs"
    class="form-select"
    :value="modelValue ?? $attrs.value"
    @change="handleChange"
  >
    <option
      v-for="action in actions"
      :key="action.id"
      :value="action.id"
    >
      {{ t(action.labelI18nKey) }}
    </option>
  </select>
</template>

<script>
import { IMPORT_ACTIONS } from '~/utils/Constants.js';
import I18n from '~/utils/I18n.js';

export default {
  props: {
    modelValue: {
      type: String,
      default: null,
    },
  },

  emits: ['update:modelValue', 'change'],

  setup(_props, { emit }) {
    const handleChange = (ev) => {
      emit('update:modelValue', ev.target.value);
      emit('change', ev.target.value);
    };

    return {
      t: I18n.scopedTranslator(''),
      actions: IMPORT_ACTIONS,
      handleChange,
    };
  },
};
</script>
