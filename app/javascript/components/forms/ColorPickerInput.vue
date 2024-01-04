<template>
  <div>
    <input
      :id="id"
      type="hidden"
      :name="name"
      :value="modelValue ?? $attrs.value"
    >
    <a
      :id="`${id}__toggler`"
      href="#"
      role="button"
      data-bs-toggle="dropdown"
      aria-expanded="false"
      class="ColorPickerInput d-block rounded-circle"
      :style="{ backgroundColor: modelValue ?? $attrs.value }"
    />
    <div
      class="dropdown-menu p-0"
      :aria-labelledby="`${id}__toggler`"
    >
      <div class="ColorPickerInput__dropdown p-2">
        <div
          v-for="color in colors"
          :key="color"
          class="ColorPickerInput__color-option"
          :style="{ backgroundColor: color }"
          @click="handleColorClick(color)"
        />
      </div>
    </div>
  </div>
</template>

<script>
import { colors } from '~/utils/ColorSwatch.js';

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
      type: String,
      default: null,
    },
  },

  emits: ['update:modelValue', 'change'],

  setup(_props, { emit }) {
    const handleColorClick = (color) => {
      emit('update:modelValue', color);
      emit('change', color);
    };

    return {
      colors,
      handleColorClick,
    };
  },
};
</script>

<style lang="scss" scoped>
@import '../../stylesheets/variables';

.ColorPickerInput {
  border: 1px solid $gray-400;
  cursor: pointer;
  width: calc((1em * $input-line-height) + (2 * $input-padding-y));
  height: calc((1em * $input-line-height) + (2 * $input-padding-y));
}

.ColorPickerInput__dropdown {
  display: grid;
  grid-template-columns: auto auto auto auto auto auto auto auto auto auto;
}

.ColorPickerInput__color-option {
  border-radius: 50%;
  cursor: pointer;
  margin: 0.1em;
  height: 1.5em;
  width: 1.5em;
}
</style>
