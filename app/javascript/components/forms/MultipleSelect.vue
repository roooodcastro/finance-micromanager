<template>
  <div class="dropdown flex-shrink-0">
    <select
      multiple
      hidden
    />

    <a
      class="form-select ps-3 py-2 border-dark text-truncate d-flex align-items-center text-decoration-none h-100"
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

    <div class="MultipleSelect__menu dropdown-menu w-100">
      <div class="d-flex mb-2">
        <a
          class="btn btn-sm btn-light p-1 mx-2 flex-grow-1 fs-6"
          @click="handleAll"
        >
          {{ t('all') }}
        </a>
        <a
          class="btn btn-sm btn-light p-1 me-2 flex-grow-1 fs-6"
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
  },

  emits: ['update:modelValue', 'change'],

  setup(props, { emit} ) {
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
.MultipleSelect__menu {
  max-height: 50vh;
  overflow-y: auto;
}
</style>
