<template>
  <Draggable
    :id="modalId"
    class="modal fade"
    tabindex="-1"
    :aria-labelledby="title"
    aria-hidden="true"
    draggable-element-selector=".modal-content"
    trigger-element-selector=".modal-header"
    v-on="{ 'shown.bs.modal': handleShown, 'show.bs.modal': handleShow }"
  >
    <div class="modal-dialog modal-dialog-centered">
      <LoadingOverlay
        :loading="loading"
        class="modal-content"
      >
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
          <template v-if="!$slots.footer">
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
          </template>

          <slot
            name="footer"
            :close-modal="closeModal"
          />
        </div>
      </LoadingOverlay>
    </div>
  </Draggable>
</template>

<script>
import { computed, onMounted } from 'vue';
import useModalStore from '~/stores/ModalStore.js';

import CloseButton from '~/components/bootstrap/CloseButton.vue';
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';
import LoadingOverlay from '~/components/layout/LoadingOverlay.vue';
import Draggable from '~/components/ui/Draggable.vue';

export default {
  components: {
    CloseButton,
    Draggable,
    FontAwesomeIcon,
    LoadingOverlay,
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
    loading: {
      type: Boolean,
      default: false,
    },
  },

  emits: ['shown', 'show'],

  setup(props, { emit }) {
    const modalStore = useModalStore();

    onMounted(() => modalStore.registerModal(props.formId));

    const isNewRecord = computed(() => !props.record?.id);
    const title = computed(() => isNewRecord.value ? props.t('new_title') : props.t('edit_title'));

    const closeModal = () => modalStore.hide(props.formId);

    const handleShow = () => emit('show');
    const handleShown = (ev) => {
      ev.target.querySelector('input.focus')?.focus();
      emit('shown');
    };

    return {
      title,
      closeModal,
      handleShown,
      handleShow,
    }
  },
};
</script>

<style lang="scss" scoped>
.FormModal__footer {
  grid-template-columns: repeat(2, minmax(max-content, 1fr));
}
</style>
