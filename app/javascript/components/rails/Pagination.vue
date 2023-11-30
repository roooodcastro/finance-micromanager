<template>
  <div class="d-none d-lg-flex justify-content-end align-items-center">
    <div
      v-if="!compact"
      class="dropdown"
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

    <div class="d-none d-lg-flex ms-3">
      {{ t('page_desc', { items: `${paginationFromStore.from}-${paginationFromStore.to}`, total: paginationFromStore.count }) }}
    </div>

    <nav
      v-if="showPageControls"
      class="ms-3"
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
    paginationFromStore.value = props.pagination;

    const showPageControls = paginationFromStore.value.count > paginationFromStore.value.items;

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
      showPageControls,
      handlePageChange,
      handlePerPageChange,
      PAGINATION_PER_PAGE_OPTIONS,
    }
  }
};
</script>
