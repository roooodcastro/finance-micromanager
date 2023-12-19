<template>
  <span
    ref="iconElement"
    class="InfoTooltip__span d-inline-block"
    data-bs-toggle="tooltip"
    data-bs-placement="bottom"
    :data-bs-title="message"
    v-html="iconSvg"
  />
</template>

<script>
import { onMounted, ref } from 'vue';
import { Tooltip as BootstrapTooltip } from 'bootstrap';

export default {
  props: {
    message: {
      type: String,
      required: true,
    },
  },

  setup() {
    const iconModules = import.meta.glob('~/images/icons/circle-icon.svg', { as: 'raw', eager: true });
    const iconSvg = iconModules[Object.keys(iconModules)];
    const iconElement = ref(null);

    onMounted(() => new BootstrapTooltip(iconElement.value));

    return {
      iconSvg,
      iconElement,
    };
  },
};
</script>

<style lang="scss" scoped>
.InfoTooltip__span {
  width: 1.2em;
  height: 1.2em;
}
</style>
