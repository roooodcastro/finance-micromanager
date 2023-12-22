<template>
  <div class="Pagination d-none d-lg-flex justify-content-end align-items-center flex-wrap">
    <div
      v-if="!compact && paginationFromStore.count"
      class="dropdown flex-shrink-0"
    >
      {{ t('per_page') }}
      <button
        type="button"
        class="btn btn-sm btn-outline-dark dropdown-toggle"
        data-bs-toggle="dropdown"
        aria-expanded="false"
      >
        {{ paginationFromStore.items }}
      </button>
      <ul class="dropdown-menu">
        <li
          v-for="perPage in PAGINATION_PER_PAGE_OPTIONS"
          :key="perPage"
        >
          <a
            class="dropdown-item"
            href="#"
            @click="handlePerPageChange(perPage)"
          >
            {{ perPage }}
          </a>
        </li>
      </ul>
    </div>

    <div
      v-if="paginationFromStore.count"
      class="d-none d-lg-flex ms-3 flex-shrink-0"
    >
      {{ t('page_desc', { items: `${paginationFromStore.from}-${paginationFromStore.to}`, total: paginationFromStore.count }) }}
    </div>

    <nav
      v-if="paginationFromStore.count && paginationFromStore.count > paginationFromStore.items"
      class="ms-3 flex-shrink-0"
      :aria-label="t('pagination')"
    >
      <div class="btn-group">
        <a
          class="btn btn-sm btn-outline-dark"
          :class="{
            'disabled': paginationFromStore.page === 1,
          }"
          :aria-disabled="paginationFromStore.page === 1"
          @click="handlePageChange(paginationFromStore.page - 1)"
        >
          <FontAwesomeIcon icon="chevron-left" />
        </a>
        <template v-if="!compact">
          <template
            v-for="(page, index) in paginationFromStore.series"
            :key="`pagination-${page}-${index}`"
          >
            <a
              class="btn btn-sm"
              :class="{
                'active disabled btn-dark': page === `${paginationFromStore.page}`,
                'disabled': page === 'gap',
                'btn-outline-dark': page !== `${paginationFromStore.page}`
              }"
              :aria-disabled="page === `${paginationFromStore.page}`"
              @click="handlePageChange(page)"
              v-html="labelForPage(page)"
            />
          </template>
        </template>
        <a
          class="btn btn-sm btn-outline-dark"
          :class="{ 'disabled': paginationFromStore.page === paginationFromStore.pages }"
          :aria-disabled="paginationFromStore.page === paginationFromStore.pages"
          @click="handlePageChange(paginationFromStore.page + 1)"
        >
          <FontAwesomeIcon icon="chevron-right" />
        </a>
      </div>
    </nav>
  </div>
</template>

<script>
import { storeToRefs } from 'pinia';

import I18n from '~/utils/I18n.js';
import { PAGINATION_PER_PAGE_OPTIONS } from '~/utils/Constants.js';
import usePaginationStore from '~/stores/PaginationStore.js';

import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';

export default {
  components: { FontAwesomeIcon },
  props: {
    pagination: {
      type: Object,
      required: true,
    },
    compact: {
      type: Boolean,
      default: false,
    },
  },

  emits: ['change'],

  setup(props, { emit }) {
    const labelForPage = page => page === 'gap' ? '&hellip;' : page;

    const paginationStore = usePaginationStore();
    const { pagination: paginationFromStore } = storeToRefs(paginationStore);
    if (props.pagination.length) {
      paginationFromStore.value = props.pagination;
    }

    const handlePageChange = (page) => {
      paginationStore.setPage(page);
      emit('change');
    }

    const handlePerPageChange = (perPage) => {
      paginationStore.setPerPage(perPage);
      emit('change');
    }

    return {
      t: I18n.scopedTranslator('views.layout.rails'),
      paginationFromStore,
      labelForPage,
      handlePageChange,
      handlePerPageChange,
      PAGINATION_PER_PAGE_OPTIONS,
    }
  }
};
</script>

<style lang="scss" scoped>
.Pagination {
  margin-top: -0.5rem;

  > * {
    margin-top: 0.5rem;
  }
}
</style>
