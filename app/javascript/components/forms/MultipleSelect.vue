<template>
  <div class="dropdown">
    <a
      class=" text-truncate bg-body"
      :class="selectClass"
      data-bs-toggle="dropdown"
      data-bs-auto-close="outside"
      aria-expanded="false"
    >
      <template v-if="selectedOptions.length === 1">
        {{ selectedOptions.length }} {{ selectionLabelOne ?? t('multiple_select_selection') }}
      </template>
      <template v-else-if="selectedOptions.length">
        {{ selectedOptions.length }} {{ selectionLabelMany ?? t('multiple_select_selections') }}
      </template>
      <template v-else>
        {{ placeholder ?? t('choose_options') }}
      </template>
    </a>

    <div class="MultipleSelect__menu dropdown-menu">
      <div class="d-flex mb-2 px-2 gap-2">
        <a
          class="btn btn-xs btn-light flex-grow-1"
          @click="handleAll"
        >
          {{ t('all') }}
        </a>
        <a
          class="btn btn-xs btn-light flex-grow-1"
          @click="handleNone"
        >
          {{ t('none') }}
        </a>
      </div>
      <a
        v-for="option in options"
        :key="option.value"
        href="#"
        class="dropdown-item d-flex align-items-center py-2"
        @click="handleOptionToggle(option.value)"
      >
        <input
          type="checkbox"
          class="me-2"
          :checked="selectedOptions.includes(option.value)"
        >

        {{ option.label }}
      </a>
    </div>
  </div>
</template>

<script>
import { ref } from 'vue';
import _ from 'lodash';

import I18n from '~/utils/I18n.js';

export default {
  props: {
    modelValue: {
      type: String,
      default: null,
    },
    placeholder: {
      type: String,
      default: null,
    },
    selectionLabelOne: {
      type: String,
      default: null,
    },
    selectionLabelMany: {
      type: String,
      default: null,
    },
    options: {
      type: Array,
      required: true,
    },
    selectClass: {
      type: [String, Object],
      default: '',
    }
  },

  emits: ['update:modelValue', 'change'],

  setup(props, { emit } ) {
    const t = I18n.scopedTranslator('views.layout.forms');

    const selectedOptions = ref((props.modelValue ?? '').split(',').filter(el => el !== ''));

    const emitChange = () => {
      emit('update:modelValue', selectedOptions.value.join(','));
      emit('change', selectedOptions.value.join(','));
    };

    const handleOptionToggle = (option) => {
      selectedOptions.value = _.xor(selectedOptions.value, [option]);
      emitChange();
    };

    const handleAll = () => {
      selectedOptions.value = props.options.map(option => option.value);
      emitChange();
    };

    const handleNone = () => {
      selectedOptions.value = [];
      emitChange();
    };

    return {
      t,
      selectedOptions,
      handleOptionToggle,
      handleAll,
      handleNone,
    };
  },
};
</script>

<style lang="scss" scoped>
@import '../../stylesheets/variables';

.MultipleSelect__menu {
  max-height: 50vh;
  overflow-y: auto;
  min-width: 100%;
}
</style>
