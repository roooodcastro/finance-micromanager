<template>
  <div>
    <label
      v-if="!!label"
      :for="formHelper?.fieldId(fieldName)"
      class="form-label"
    >
      {{ label }}
    </label>

    <select
      v-bind="$attrs"
      :id="formHelper?.fieldId(fieldName)"
      :name="formHelper?.fieldName(fieldName)"
      :value="modelValue ?? $attrs.value"
      class="form-select"
      @change="handleChange"
    >
      <option
        v-for="option in options"
        :key="option.value"
        :value="option.value"
      >
        {{ option.label }}
      </option>
    </select>
  </div>
</template>

<script>
export default {
  props: {
    options: {
      type: Array,
      required: true,
    },
    fieldName: {
      type: String,
      required: true,
    },
    formHelper: {
      type: Object,
      default: null,
    },
    label: {
      type: String,
      default: null,
    },
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
      handleChange,
    };
  },
};
</script>
