<template>
  <div class="form-floating mb-3">
    <input
      v-bind="$attrs"
      :type="type"
      class="form-control"
      :id="formHelper.fieldId(fieldName)"
      :name="formHelper.fieldName(fieldName)"
      :placeholder="label"
    >
    <label :for="formHelper.fieldId(fieldName)">
      {{ label }}
    </label>
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
