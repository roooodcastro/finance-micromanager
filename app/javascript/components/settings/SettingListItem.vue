<template>
  <div class="row border-bottom py-3 align-items-center">
    <FontAwesomeIcon
      :icon="icon"
      size="3x"
      class="col-2 col-lg-1 icon-secondary my-1"
    />

    <div
      class="col"
      :class="{ 'text-muted': !value }"
    >
      <span
        v-if="!!label"
        class="fw-bold me-3"
      >
        {{ label }}:
      </span>
      {{ value || emptyLabel }}
    </div>
  </div>
</template>

<script>
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';

export default {
  components: {
    FontAwesomeIcon,
  },

  props: {
    icon: {
      type: String,
      required: true,
    },
    value: {
      type: String,
      required: true,
    },
    label: {
      type: String,
      default: '',
    },
    emptyLabel: {
      type: String,
      default: '',
    },
  },
};
</script>
