<template>
  <div class="card overflow-hidden">
    <div class="CollapsibleCard__card-header card-header">
      <h5 class="m-0">
        <a
          data-bs-toggle="collapse"
          class="d-block text-dark text-decoration-none"
          :class="{ 'collapsed': isCollapsed }"
          :href="`#${id}`"
        >
          <FontAwesomeIcon icon="chevron-down" />
          {{ title }}
        </a>
      </h5>

      <slot name="header" />
    </div>
    <template v-if="noBody">
      <div
        :id="id"
        class="collapse"
        :class="{ 'show': !isCollapsed }"
        v-on="{ 'show.bs.collapse': handleShow, 'hide.bs.collapse': handleHide }"
      >
        <slot />
      </div>
    </template>
    <div
      v-else
      :id="id"
      class="collapse"
      :class="{ 'show': !isCollapsed }"
      v-on="{ 'show.bs.collapse': handleShow, 'hide.bs.collapse': handleHide }"
    >
      <div class="card-body">
        <slot />
      </div>
    </div>
  </div>
</template>

<script>
import Cookies from 'js-cookie';
import _ from 'lodash';
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';

import { COLLAPSED_CARDS_COOKIE_NAME } from '~/utils/Constants.js';

export default {
  components: {
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
  },

  setup(props) {
    const allCollapsedCards = Cookies.get(COLLAPSED_CARDS_COOKIE_NAME)?.split(',') ?? [];

    const isCollapsed = allCollapsedCards.includes(props.id);

    const handleShow = () => {
      let allCollapsedCards = Cookies.get(COLLAPSED_CARDS_COOKIE_NAME)?.split(',') ?? [];
      allCollapsedCards = allCollapsedCards.filter(item => item !== props.id);
      Cookies.set(COLLAPSED_CARDS_COOKIE_NAME, allCollapsedCards.join(','));
    };

    const handleHide = () => {
      let allCollapsedCards = Cookies.get(COLLAPSED_CARDS_COOKIE_NAME)?.split(',') ?? [];
      allCollapsedCards = _.union(allCollapsedCards, [props.id]);
      Cookies.set(COLLAPSED_CARDS_COOKIE_NAME, allCollapsedCards.join(','));
    };

    return {
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
