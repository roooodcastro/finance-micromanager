<template>
  <button
    type="button"
    class="btn-close"
    :data-bs-dismiss="dismiss"
    aria-label="Close"
  />
</template>

<script>
export default {
  props: {
    dismiss: {
      type: String,
      default: 'alert',
    },
  },
};
</script>
