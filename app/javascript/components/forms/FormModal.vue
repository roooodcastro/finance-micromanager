<template>
  <div
    :id="modalId"
    class="modal fade"
    tabindex="-1"
    :aria-labelledby="title"
    aria-hidden="true"
  >
    <div class="modal-dialog modal-dialog-centered">
      <div class="modal-content">
        <div class="modal-header">
          <h5 class="modal-title">
            {{ title }}
          </h5>
          <CloseButton dismiss="modal" />
        </div>
        <div
          v-if="record"
          class="modal-body"
        >
          <slot :close-modal="closeModal" />
        </div>
        <div class="FormModal__footer d-grid d-lg-flex gap-2 modal-footer">
          <button
            type="button"
            class="btn btn-outline-secondary"
            data-bs-dismiss="modal"
          >
            <FontAwesomeIcon
              :icon="['far', 'circle-xmark']"
              class="me-2"
            />

            {{ t('cancel') }}
          </button>
          <button
            type="submit"
            :form="formId"
            class="btn btn-primary"
          >
            <FontAwesomeIcon
              icon="floppy-disk"
              class="me-lg-2"
            />

            {{ t('submit') }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, computed, onMounted } from 'vue';
import { Modal as BootstrapModal } from 'bootstrap';

import CloseButton from '~/components/bootstrap/CloseButton.vue';
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';

export default {
  components: {
    CloseButton,
    FontAwesomeIcon,
  },

  props: {
    modalId: {
      type: String,
      required: true,
    },
    formId: {
      type: String,
      required: true,
    },
    record: {
      type: Object,
      required: true,
    },
    t: {
      type: Function,
      required: true,
    },
  },

  setup(props) {
    const modal = ref(null);

    onMounted(() => modal.value = new BootstrapModal(`#${props.modalId}`));

    const isNewRecord = computed(() => !props.record.value?.id);
    const title = computed(() => isNewRecord.value ? props.t('new_title') : props.t('edit_title'));

    const closeModal = () => {
      modal.value.hide();
    };

    return {
      title,
      closeModal,
    }
  },
};
</script>

<style lang="scss" scoped>
.FormModal__footer {
  grid-template-columns: repeat(2, 1fr);
}
</style>