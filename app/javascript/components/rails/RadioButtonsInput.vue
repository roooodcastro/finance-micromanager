<template>
  <div class="mb-3 gap-2 d-flex">
    <template
      v-for="option in options"
      :key="option.value"
    >
      <input
        :id="`${formHelper.fieldId(fieldName)}_${option.value}`"
        :name="`${formHelper.fieldName(fieldName)}`"
        type="radio"
        class="btn-check"
        :value="option.value"
        :checked="option.checked"
        autocomplete="off"
      >
      <label
        class="btn btn-outline-primary btn-sm flex-fill"
        :for="`${formHelper.fieldId(fieldName)}_${option.value}`"
      >
        {{ option.label }}
      </label>
    </template>
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
    options: {
      type: Array,
      required: true,
    },
  }
};
</script>
