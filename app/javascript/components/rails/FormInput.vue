<template>
  <div class="mb-3">
    <label
      :for="formHelper.fieldId(fieldName)"
      class="form-label"
    >
      {{ label }}
    </label>

    <div class="input-group">
      <span
        v-if="!!prepend"
        class="input-group-text"
      >
        {{ prepend }}
      </span>

      <input
        v-bind="$attrs"
        :id="formHelper.fieldId(fieldName)"
        :type="type"
        class="form-control"
        :name="formHelper.fieldName(fieldName)"
        :value="modelValue ?? $attrs.value"
        @input="$emit('update:modelValue', $event.target.value)"
      >
    </div>

    <div
      v-if="formHelper.hasError(fieldName)"
      class="invalid-feedback"
    >
      {{ formHelper.errorFor(fieldName) }}
    </div>
  </div>
</template>

<script>
export default {
  props: {
    fieldName: {
      type: String,
      required: true,
    },
    formHelper: {
      type: Object,
      required: true,
    },
    label: {
      type: String,
      required: true,
    },
    type: {
      type: String,
      default: 'text',
    },
    prepend: {
      type: String,
      default: null,
    },
    modelValue: {
      type: String,
      default: null,
    },
  },

  emits: ['update:modelValue'],
};
</script>
