<template>
  <div class="FloatingActionButton position-sticky end-0 bottom-0 py-3 pe-3">
    <a
      class="FloatingActionButton__link d-flex align-items-center justify-content-center btn btn-primary rounded-circle fs-1 shadow"
      href="#"
      @click="handleClick"
    >
      <FontAwesomeIcon icon="plus" />
    </a>
  </div>
</template>

<script>
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';

import useTransactionStore from '~/stores/TransactionStore.js';

export default {
  components: {
    FontAwesomeIcon,
  },

  setup() {
    const transactionStore = useTransactionStore();

    const handleClick = () => transactionStore.openFormModal(null);

    return { handleClick };
  }
};
</script>

<style lang="scss" scoped>
.FloatingActionButton {
  z-index: 1;
  margin: auto 0 -1rem auto;
}

.FloatingActionButton__link {
  width: 4rem;
  height: 4rem;
}
</style>
