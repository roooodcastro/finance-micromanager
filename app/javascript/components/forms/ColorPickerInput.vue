<template>
  <div>
    <input
      :id="id"
      type="hidden"
      :name="name"
      :value="colorValue"
    />
    <a
      :id="`${id}__toggler`"
      href="#"
      role="button"
      data-bs-toggle="dropdown"
      aria-expanded="false"
      class="ColorPickerInput d-block rounded-circle"
      :style="{ backgroundColor: colorValue }"
    >
    </a>
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
        >
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { toRef } from 'vue';

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
    value: {
      type: String,
      default: null,
    },
  },
  setup(props) {
    const colorValue = toRef(props.value);
    const handleColorClick = (color) => {
      colorValue.value = color;
    };

    return {
      colors,
      colorValue,
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
