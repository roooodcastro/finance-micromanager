<template>
  <div class="form-floating mb-3">
    <input
      v-bind="$attrs"
      :id="formHelper.fieldId(fieldName)"
      :type="type"
      class="form-control"
      :class="{ 'is-invalid': formHelper.hasError(fieldName) }"
      :name="formHelper.fieldName(fieldName)"
      :placeholder="label"
    >
    <label :for="formHelper.fieldId(fieldName)">
      {{ label }}
    </label>
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
  },
};
</script>
