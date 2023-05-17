<template>
  <div class="mb-3">
    <label
      :for="formHelper.fieldId(fieldName)"
      class="form-label"
    >
      {{ label }}
    </label>
    <input
      v-bind="$attrs"
      :id="formHelper.fieldId(fieldName)"
      :type="type"
      class="form-control"
      :name="formHelper.fieldName(fieldName)"
    >
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
