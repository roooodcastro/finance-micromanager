<template>
  <div class="row align-items-center">
    <div class="col-7 col-md-9 col-lg-8 col-xl-9 d-flex align-items-stretch text-decoration-none text-body">
      <span
        class="CategoriesList__color-indicator me-2"
        :style="{ backgroundColor: indicatorColor }"
      />

      <span
        class="CategoriesList__verticalPipe"
        :class="{ 'CategoriesList__verticalPipe-last': lastChild }"
      />
      <span class="CategoriesList__horizontalPipe me-2" />

      <span class="py-2 fs-6">
        {{ label }}
      </span>
    </div>

    <div
      class="col text-end fw-bold me-2 fs-6"
      :class="{ 'text-credit': amount > 0, 'text-debit': amount < 0 }"
    >
      {{ formatMoney(amount) }}
    </div>
  </div>
</template>

<script>
import { formatMoney } from '~/utils/NumberFormatter.js';

export default {
  props: {
    indicatorColor: {
      type: String,
      required: true,
    },
    label: {
      type: String,
      required: true,
    },
    amount: {
      type: Number,
      required: true,
    },
    lastChild: {
      type: Boolean,
      default: false,
    },
  },

  setup() {
    return {
      formatMoney,
    };
  }
};
</script>

<style lang="scss" scoped>
@import '../../../stylesheets/variables';

.CategoriesList__color-indicator {
  display: inline-block;
  width: 0.5em;
}

.CategoriesList__horizontalPipe {
  display: inline-block;
  border-bottom: 2px solid $border-color-translucent;
  height: 1px;
  width: 0.5rem;
  margin-top: auto;
  margin-bottom: auto;
}

.CategoriesList__verticalPipe {
  display: inline-block;
  border-right: 2px solid $border-color-translucent;
  width: 1px;
}

.CategoriesList__verticalPipe-last {
  margin-bottom: 1rem;
}
</style>
