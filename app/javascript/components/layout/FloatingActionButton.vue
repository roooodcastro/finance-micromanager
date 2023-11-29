<template>
  <div class="FloatingActionButton position-sticky end-0 bottom-0 py-3 pe-3">
    <a
      class="FloatingActionButton__link d-flex align-items-center justify-content-center btn btn-primary rounded-circle fs-1 shadow"
      :href="newTransactionPath"
    >
      <FontAwesomeIcon icon="plus" />
    </a>
  </div>
</template>

<script>
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';

import { transactions as transactionsApi } from '~/api';

export default {
  components: {
    FontAwesomeIcon,
  },

  setup() {
    const newTransactionPath = transactionsApi.new.path();

    return { newTransactionPath };
  }
};
</script>

<style lang="scss" scoped>
.FloatingActionButton {
  z-index: 1;
  margin-top: auto;
  margin-bottom: -1rem;
  margin-left: calc(((100% - 100vw) / 2) + 100vw - 5rem);
}

.FloatingActionButton__link {
  width: 4rem;
  height: 4rem;
}
</style>
