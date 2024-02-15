<template>
  <div class="card overflow-hidden">
    <div
      class="CollapsibleCard__card-header card-header"
      :class="{ 'border-bottom-0': isCollapsed }"
    >
      <div :class="headerClass">
        <h5 class="m-0">
          <a
            data-bs-toggle="collapse"
            class="d-block text-dark text-decoration-none"
            :class="{ 'collapsed': isInitiallyCollapsed }"
            :href="`#${id}`"
          >
            <FontAwesomeIcon icon="chevron-down" />
            {{ title }}
          </a>
        </h5>

        <slot
          v-if="!isCollapsed"
          name="header"
        />
      </div>
    </div>
    <template v-if="noBody">
      <LoadingOverlay
        :id="id"
        class="collapse"
        :class="{ 'show': !isInitiallyCollapsed }"
        :loading="loading"
        v-on="{ 'show.bs.collapse': handleShow, 'hide.bs.collapse': handleHide }"
      >
        <slot />
      </LoadingOverlay>
    </template>
    <LoadingOverlay
      v-else
      :id="id"
      class="collapse"
      :class="{ 'show': !isInitiallyCollapsed }"
      :loading="loading"
      v-on="{ 'show.bs.collapse': handleShow, 'hide.bs.collapse': handleHide }"
    >
      <div class="card-body">
        <slot />
      </div>
    </LoadingOverlay>
  </div>
</template>

<script>
import { computed, ref } from 'vue';
import Cookies from 'js-cookie';
import _ from 'lodash';
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';

import { COLLAPSED_CARDS_COOKIE_NAME } from '~/utils/Constants.js';
import LoadingOverlay from '~/components/layout/LoadingOverlay.vue';

export default {
  components: {
    LoadingOverlay,
    FontAwesomeIcon
  },

  props: {
    id: {
      type: String,
      required: true,
    },
    title: {
      type: String,
      default: '',
    },
    noBody: {
      type: Boolean,
      default: false,
    },
    loading: {
      type: Boolean,
      default: false,
    },
    headerClass: {
      type: String,
      default: '',
    }
  },

  setup(props) {
    const allCollapsedCards = ref(Cookies.get(COLLAPSED_CARDS_COOKIE_NAME)?.split(',') ?? []);

    const isCollapsed = computed(() => allCollapsedCards.value.includes(props.id));
    const isInitiallyCollapsed = allCollapsedCards.value.includes(props.id);

    const handleShow = () => {
      allCollapsedCards.value = Cookies.get(COLLAPSED_CARDS_COOKIE_NAME)?.split(',') ?? [];
      allCollapsedCards.value = allCollapsedCards.value.filter(item => item !== props.id);
      Cookies.set(COLLAPSED_CARDS_COOKIE_NAME, allCollapsedCards.value.join(','));
    };

    const handleHide = () => {
      allCollapsedCards.value = Cookies.get(COLLAPSED_CARDS_COOKIE_NAME)?.split(',') ?? [];
      allCollapsedCards.value = _.union(allCollapsedCards.value, [props.id]);
      Cookies.set(COLLAPSED_CARDS_COOKIE_NAME, allCollapsedCards.value.join(','));
    };

    return {
      isInitiallyCollapsed,
      isCollapsed,
      handleShow,
      handleHide,
    };
  },
};
</script>

<style lang="scss" scoped>
.CollapsibleCard__card-header {
  padding: 0;

  a {
    padding: var(--bs-card-cap-padding-y) var(--bs-card-cap-padding-x);
  }

  svg {
    transition: transform 0.2s linear;
  }

  a.collapsed {
    svg {
      transform: rotate(-90deg);
    }
  }
}
</style>
