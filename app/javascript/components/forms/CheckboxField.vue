<template>
  <div class="form-check">
    <input
      :id="id"
      :name="name"
      class="form-check-input"
      type="checkbox"
      :value="onValue"
      :checked="modelValue ?? $attrs.value"
      @input="handleInput"
    >
    <label
      class="form-check-label"
      :for="id"
    >
      <slot />
    </label>
  </div>
</template>

<script>
export default {
  props: {
    id: {
      type: String,
      required: true,
    },
    name: {
      type: String,
      default: null,
    },
    modelValue: {
      type: [String, Boolean],
      default: null,
    },
    offValue: {
      type: [String, Boolean],
      default: false,
    },
    onValue: {
      type: [String, Boolean],
      default: true,
    },
  },

  emits: ['update:modelValue', 'change'],

  setup(props, { emit }) {
    const handleInput = (ev) => {
      emit('change', ev);
      emit('update:modelValue', ev.target.checked ? props.onValue : props.offValue);
    };

    return {
      handleInput,
    };
  }
};
</script>
