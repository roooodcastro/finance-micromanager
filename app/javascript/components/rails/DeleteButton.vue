<template>
  <a
    v-bind="$attrs"
    class="text-danger"
    @click="handleClick"
  >
    <FontAwesomeIcon
      :icon="disableLabel ? 'ban' : ['far', 'trash-can']"
      size="lg"
    />
    <span
      v-if="!compact"
      class="d-none d-lg-inline-block ms-2"
    >
      {{ disableLabel ? t('disable') : t('delete') }}
    </span>
  </a>
</template>

<script>
import I18n from '~/utils/I18n.js';
import useModalStore from '~/stores/ModalStore.js';

import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';

export default {
  components: {
    FontAwesomeIcon,
  },

  props: {
    disableLabel: {
      type: Boolean,
      default: false,
    },
    compact: {
      type: Boolean,
      default: false,
    },
    askConfirmation: {
      type: Boolean,
      default: false,
    },
  },

  emits: ['delete'],

  setup(props, { emit }) {
    const t = I18n.scopedTranslator('views.layout.rails');

    const modalStore = useModalStore();

    const confirmationMessage = props.disableLabel ? t('disable_confirmation') : t('delete_confirmation');
    const handleClick = () => {
      if (props.askConfirmation) {
        modalStore
          .showConfirmationDialog({ message: confirmationMessage })
          .then(() => emit('delete'))
          .catch(() => {});
      } else {
        emit('delete');
      }
    };

    return {
      t,
      handleClick,
    };
  },
};
</script>
