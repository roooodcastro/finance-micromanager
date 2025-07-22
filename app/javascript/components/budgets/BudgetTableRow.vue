<template>
  <div class="GridRow__left">
    <div class="d-flex gap-2 align-items-center">
      <span>
        {{ category.name }}
      </span>
    </div>
  </div>
  <div class="GridRow__right">
    <div v-if="budget.id && !budget.disabledAt">
      {{ budget.formattedLimit }}
    </div>
    <div v-else>
      -
    </div>
  </div>
</template>

<script>
export default {
  props: {
    category: {
      type: Object,
      required: true,
    },
    budget: {
      type: Object,
      required: true,
    },
  },
};
</script>
