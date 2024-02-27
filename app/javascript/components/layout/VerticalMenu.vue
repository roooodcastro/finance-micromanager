<template>
  <div :class="{ 'VerticalMenu__desktop shadow': !offcanvas }">
    <MenuProfileSection
      v-if="isUserLoggedIn"
      :class="{ 'shadow': offcanvas }"
      :offcanvas="offcanvas"
    />

    <div class="d-flex flex-column justify-content-between flex-grow-1 mt-4">
      <div class="list-group">
        <a
          v-for="menuItem in menuItems.top"
          :key="menuItem.label"
          :href="menuItem.path"
          class="VerticalMenu__item-link list-group-item list-group-item-action border-0 rounded-0"
          :class="{ active: menuItem.active, 'py-3': !offcanvas }"
          :data-method="menuItem.method || 'GET'"
        >
          <FontAwesomeIcon
            :icon="menuItem.icon"
            size="lg"
            class="me-4"
          />

          <span>{{ menuItem.label }}</span>
        </a>
      </div>

      <div class="list-group">
        <hr>

        <a
          v-for="menuItem in menuItems.bottom"
          :key="menuItem.label"
          :href="menuItem.path"
          class="VerticalMenu__item-link list-group-item list-group-item-action border-0 rounded-0"
          :class="{ active: menuItem.active, 'py-3': !offcanvas }"
          :data-method="menuItem.method || 'GET'"
        >
          <FontAwesomeIcon
            :icon="menuItem.icon"
            size="lg"
            class="me-4"
          />

          <span>{{ menuItem.label }}</span>
        </a>
      </div>
    </div>
  </div>
</template>

<script>
import { computed } from 'vue';

import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';

import useUserStore from '~/stores/UserStore.js';
import { buildVerticalMenuItems } from '~/utils/VerticalMenu.js';

import MenuProfileSection from '~/components/layout/MenuProfileSection.vue';

export default {
  components: {
    FontAwesomeIcon,
    MenuProfileSection,
  },

  props: {
    offcanvas: {
      type: Boolean,
      default: false,
    },
  },

  setup() {
    const userStore = useUserStore();
    const isUserLoggedIn = computed(() => userStore.isUserLoggedIn);
    const menuItems = buildVerticalMenuItems();

    return {
      menuItems,
      isUserLoggedIn,
    };
  },
}
</script>

<style lang="scss" scoped>
@import '../../stylesheets/variables';

.VerticalMenu__desktop {
  background-color: $gray-300;
  flex-grow: 1;
  height: 100vh;
  margin-left: -1rem;
  max-width: 25rem;
  min-width: 20rem;
  position: sticky;
  top: $main-navbar-height;
}

.VerticalMenu__item-link {
  background-color: transparent;
  border-right: 5px solid transparent !important;
  transition: all 0.1s linear;

  span {
    display: inline-block;
    transition: transform 0.1s linear;
  }
  svg {
    transition: transform 0.1s linear;
    width: 2rem;
  }

  &:hover, &:active, &:focus, &.active {
    color: color-contrast($primary);
    background-color: rgba(var(--bs-primary-rgb), var(--bs-bg-opacity, 1));
    border-right: 5px solid $primary-text-emphasis !important;

    svg {
      transform: scale(1.25);
    }
    span {
      transform: translateX(0.5rem);
    }
  }
}
</style>
