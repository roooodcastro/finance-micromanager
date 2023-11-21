<template>
  <div class="FloatingActionButton position-fixed end-0 bottom-0 me-3 mb-3">
    <a
      class="FloatingActionButton__link d-flex align-items-center justify-content-center btn btn-primary rounded-circle fs-1"
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
}

.FloatingActionButton__link {
  width: 4rem;
  height: 4rem;
}
</style>
