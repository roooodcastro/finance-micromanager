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
import { computed } from 'vue';
import _ from 'lodash';

import { IMPORT_ACTIONS } from '~/utils/Constants.js';
import I18n from '~/utils/I18n.js';

export default {
  props: {
    modelValue: {
      type: String,
      default: null,
    },
    allowMatch: {
      type: Boolean,
      required: true,
    },
  },

  emits: ['update:modelValue', 'change'],

  setup(props, { emit }) {
    const allowedActions = computed(() => {
      return _.reject(IMPORT_ACTIONS, (action) => {
        const rejectMatch = action.id === 'match' && !props.allowMatch;
        const rejectBlock = action.id === 'block';

        return rejectMatch || rejectBlock;
      });
    });

    const handleChange = (ev) => {
      emit('update:modelValue', ev.target.value);
      emit('change', ev.target.value);
    };

    return {
      t: I18n.scopedTranslator(''),
      actions: allowedActions,
      handleChange,
    };
  },
};
</script>
