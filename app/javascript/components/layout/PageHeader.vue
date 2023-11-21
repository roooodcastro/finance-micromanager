<template>
  <header v-if="title || $slots.default">
    <div class="d-flex align-items-center justify-content-between mt-2 mt-lg-4">
      <h1
        v-if="title || $slots.default"
        class="d-flex align-items-center mb-0 mb-lg-2"
      >
        <template v-if="title">
          {{ title }}
        </template>
        <slot v-else />

        <template v-if="subTitle">
          <small class="text-muted d-block">
            {{ subTitle }}
          </small>
        </template>
      </h1>

      <div>
        <slot name="actions" />
      </div>
    </div>

    <hr />
  </header>
</template>

<script>
export default {
  props: {
    title: {
      type: String,
      default: null,
    },
    subTitle: {
      type: String,
      default: '',
    },
    pageTitle: {
      type: String,
      default: '',
    },
  },
  setup(props) {
    if (props.pageTitle || props.title) {
      document.title = `${props.pageTitle || props.title} - Finance MicroManager`;
    }
  },
};
</script>
