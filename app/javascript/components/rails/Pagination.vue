<template>
  <div
    v-if="pagination.count > pagination.items"
    class="d-flex justify-content-center justify-content-lg-between"
  >
    <nav :aria-label="t('pagination')">
      <div class="btn-group">
        <a
          class="btn btn-sm btn-outline-secondary rounded-pill-start"
          :class="{
            'disabled': pagination.page === 1,
          }"
          :aria-disabled="pagination.page === 1"
          @click="$emit('change', pagination.page - 1)"
        >
          {{ t('page_prev') }}
        </a>
        <a
          v-for="page in pagination.pages"
          :key="`pagination-${page}`"
          class="btn btn-sm btn-outline-secondary"
          :class="{ 'active disabled': page === pagination.page }"
          :aria-disabled="page === pagination.page"
          @click="$emit('change', page)"
        >
          {{ page }}
        </a>
        <a
          class="btn btn-sm btn-outline-secondary rounded-pill-end"
          :class="{
            'disabled': pagination.page === pagination.pages,
          }"
          :aria-disabled="pagination.page === pagination.pages"
          @click="$emit('change', pagination.page + 1)"
        >
          {{ t('page_next') }}
        </a>
      </div>
    </nav>

    <div class="d-none d-lg-flex">
      {{ t('page_desc', { items: `${pagination.from}-${pagination.to}`, total: pagination.count }) }}
    </div>
  </div>
</template>

<script>
import I18n from '~/utils/I18n.js';

export default {
  props: {
    pagination: {
      type: Object,
      required: true,
    },
  },

  emits: ['change'],

  setup() {
    return {
      t: I18n.scopedTranslator('views.layout.rails'),
    }
  }
};
</script>
