<template>
  <div class="ToggleSwitch form-check form-switch">
    <input
      type="hidden"
      :value="offValue"
      :disabled="disabled"
    >
    <input
      :id="formHelper.fieldId(fieldName)"
      ref="input"
      :name="formHelper.fieldName(fieldName)"
      class="form-check-input"
      type="checkbox"
      role="switch"
      :labelon="onLabel"
      :labeloff="offLabel"
      :value="onValue"
      :checked="onValue === modelValue"
      :class="inputCssClasses"
      :disabled="disabled"
      @input="handleInput"
    >
  </div>
</template>

<script>
import { ref, watch } from 'vue';

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
    modelValue: {
      type: String,
      default: null,
    },
    inputOffClasses: {
      type: String,
      default: '',
    },
    inputOnClasses: {
      type: String,
      default: '',
    },
    offValue: {
      type: String,
      default: null,
    },
    onValue: {
      type: String,
      default: 'on',
    },
    offLabel: {
      type: String,
      default: 'Off',
    },
    onLabel: {
      type: String,
      default: 'On',
    },
    disabled: {
      type: Boolean,
      default: false,
    },
  },

  emits: ['update:modelValue'],

  setup(props, { emit }) {
    const input = ref(null);
    const inputCssClasses = ref({});

    const setInputCssClasses = () => {
      inputCssClasses.value[props.inputOnClasses] = input.value?.checked;
      inputCssClasses.value[props.inputOffClasses] = !input.value?.checked;
    };

    setInputCssClasses();

    watch(
      () => props.modelValue,
      () => {
        input.value.checked = props.modelValue === props.onValue;
        setInputCssClasses();
      }
    );


    const handleInput = (ev) => {
      if (!props.disabled) {
        setInputCssClasses();
        emit('update:modelValue', ev.target.checked ? props.onValue : props.offValue);
      }
    };

    return {
      input,
      inputCssClasses,
      handleInput,
    };
  },
};
</script>

<style lang="scss" scoped>
@import '../../stylesheets/variables';

.ToggleSwitch {
  margin-bottom: 0;

  .form-check-input {
    --bs-form-switch-bg: #{escape-svg(url("data:image/svg+xml,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 4 8'><rect width='4' height='8' rx='1' fill='#{$form-switch-checked-color}'/></svg>"))};
    border-radius: $input-border-radius;
    box-sizing: content-box;
    height: 3rem;
    margin-top: 0;
    position: relative;
    overflow: hidden;
    width: 8rem;

    &:checked {
      --bs-form-switch-bg: #{escape-svg(url("data:image/svg+xml,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 4 8'><rect width='4' height='8' rx='1' fill='#{$form-switch-checked-color}'/></svg>"))};
      color: $white;

      &::before {
        left: 100%;
      }
      &::after {
        left: 0;
      }
    }

    &::before {
      content: attr(labeloff);
      position: absolute;
      font-size: $font-size-sm;
      font-weight: $btn-font-weight;
      text-transform: uppercase;
      text-align: center;
      left: 1.25rem;
      letter-spacing: 1px;
      line-height: 1.5rem;
      padding: 0.75rem 0;
      width: calc(100% - 1.25rem);
      transition: all .15s ease-in-out;
    }

    &::after {
      content: attr(labelon);
      position: absolute;
      font-size: $font-size-sm;
      font-weight: $btn-font-weight;
      text-transform: uppercase;
      text-align: center;
      left: -100%;
      letter-spacing: 1px;
      line-height: 1.5rem;
      padding: 0.75rem 0;
      width: calc(100% - 1.25rem);
      transition: all .15s ease-in-out;
    }
  }
}
</style>
