<template>
  <div
    :id="modalId"
    class="modal fade"
    tabindex="-1"
    :aria-labelledby="title"
    aria-hidden="true"
    v-on="{ 'shown.bs.modal': handleShown, 'show.bs.modal': handleShow }"
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
import { computed, onMounted } from 'vue';
import useModalStore from '~/stores/ModalStore.js';

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

  emits: ['shown', 'show'],

  setup(props, { emit }) {
    const modalStore = useModalStore();

    onMounted(() => modalStore.registerModal(props.formId));

    const isNewRecord = computed(() => !props.record.value?.id);
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
  grid-template-columns: repeat(2, 1fr);
}
</style>
