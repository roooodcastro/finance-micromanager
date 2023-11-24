<template>
  <div
    v-if="pagination.count > pagination.items"
    class="d-flex justify-content-center justify-content-lg-between align-items-center"
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
        <template
          v-for="(page, index) in pagination.series"
          :key="`pagination-${page}-${index}`"
        >
          <a
            class="btn btn-sm"
            :class="{
              'active disabled btn-secondary': page === `${pagination.page}`,
              'disabled': page === 'gap',
              'btn-outline-secondary': page !== `${pagination.page}`
            }"
            :aria-disabled="page === `${pagination.page}`"
            @click="$emit('change', page)"
            v-html="labelForPage(page)"
          />
        </template>
        <a
          class="btn btn-sm btn-outline-secondary rounded-pill-end"
          :class="{ 'disabled': pagination.page === pagination.pages }"
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
    const labelForPage = page => page === 'gap' ? '&hellip;' : page;
    return {
      t: I18n.scopedTranslator('views.layout.rails'),
      labelForPage,
    }
  }
};
</script>
