<template>
  <RailsForm
    :action="updatePath"
    resource="import"
    method="PATCH"
  >
    <slot />
  </RailsForm>
</template>

<script>
import { imports as importsApi } from '~/api/all.js';

import RailsForm from '~/components/rails/RailsForm.vue';

export default {
  components: {
    RailsForm,
  },

  props: {
    importObject: {
      type: Object,
      required: true,
    },
  },

  setup(props) {
    const updatePath = importsApi.update.path({ id: props.importObject.id });

    return { updatePath };
  },
};
</script>
