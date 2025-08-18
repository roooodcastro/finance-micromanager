<template>
  <div
    :id="HELP_MODAL_ID"
    class="modal"
    tabindex="-1"
  >
    <div class="modal-dialog modal-dialog-centered modal-dialog-scrollable">
      <div class="modal-content">
        <div class="modal-header">
          <h5 class="modal-title">
            <FontAwesomeIcon
              :icon="['far', 'circle-question']"
              size="lg"
              class="text-info"
            />
            {{ title }}
          </h5>
          <CloseButton dismiss="modal" />
        </div>
        <div
          class="modal-body"
          v-html="message"
        />
      </div>
    </div>
  </div>
</template>

<script>
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';

import { HELP_MODAL_ID } from '~/utils/Constants.js';

import CloseButton from '~/components/bootstrap/CloseButton.vue';

export default {
  components: {
    CloseButton,
    FontAwesomeIcon,
  },

  props: {
    title: {
      type: String,
      required: true,
    },

    message: {
      type: String,
      required: true,
    },
  },

  setup() {
    return { HELP_MODAL_ID };
  },
}
</script>
