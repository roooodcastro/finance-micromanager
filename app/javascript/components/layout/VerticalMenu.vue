<template>
  <div :class="{ 'VerticalMenu__desktop shadow': !offcanvas }">
    <MenuProfileSection
      v-if="isUserLoggedIn"
      :class="{ 'shadow': offcanvas }"
      :offcanvas="offcanvas"
    />

    <div class="d-flex flex-column justify-content-between flex-grow-1 pt-4 overflow-y-auto">
      <div class="list-group">
        <template
          v-for="menuItem in menuItems.top"
          :key="menuItem.label"
        >
          <a
            :href="menuItem.path"
            class="VerticalMenu__item-link list-group-item list-group-item-action border-0 rounded-0 d-flex justify-content-between align-items-center"
            :class="{
              active: menuItem.active,
              collapsed: !menuItem.expanded,
              'py-3': !offcanvas,
              'pe-0': menuItem.hasSubMenu,
            }"
            :data-method="menuItem.method || null"
            :data-bs-toggle="menuItem.hasSubMenu ? 'collapse' : null"
          >
            <div>
              <FontAwesomeIcon
                :icon="menuItem.icon"
                size="lg"
                class="me-3 me-lg-4"
              />

              <span>{{ menuItem.label }}</span>
            </div>

            <FontAwesomeIcon
              v-if="menuItem.hasSubMenu"
              icon="chevron-down"
              class="VerticalMenu__collapseIndicator"
            />
          </a>

          <div
            v-if="menuItem.hasSubMenu"
            :id="`collapse_${menuItem.key}`"
            class="collapse"
            :class="{ show: menuItem.expanded }"
          >
            <a
              v-for="submenuItem in menuItem.subItems"
              :key="submenuItem.label"
              :href="submenuItem.path"
              class="VerticalMenu__item-link list-group-item list-group-item-action border-0 rounded-0 ps-5"
              :class="{ active: submenuItem.active, 'py-3': !offcanvas }"
              :data-method="submenuItem.method || 'GET'"
            >
              <FontAwesomeIcon
                :icon="submenuItem.icon"
                size="lg"
                class="me-4"
              />

              <span>{{ submenuItem.label }}</span>
            </a>
          </div>
        </template>
      </div>

      <div class="list-group">
        <hr class="mx-3">

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
  height: calc(100vh - $main-navbar-height);
  margin-left: -1rem;
  max-width: 25rem;
  min-width: 20rem;
  position: sticky;
  top: $main-navbar-height;
}

.VerticalMenu__item-link {
  background-color: transparent;
  border-right: 5px solid transparent !important;
  transition: all 0.15s ease-in-out;

  span {
    display: inline-block;
    transition: transform 0.15s ease-in-out;
  }
  svg {
    transition: transform 0.15s ease-in-out;
    width: 2rem;
  }


  &:hover, &:active, &:focus, &.active {
    border-right: 5px solid $primary-text-emphasis !important;

    svg {
      transform: scale(1.2);
    }
    span {
      transform: translateX(0.5rem);
    }
  }

  &:active, &.active {
    color: color-contrast(rgba($primary, 0.8));
    background-color: rgba($primary, 0.8);
  }

  &:hover, &:focus {
    color: color-contrast($primary);
    background-color: $primary;
  }

  .VerticalMenu__collapseIndicator {
    transition: transform 0.3s ease-in-out;
  }

  &.collapsed .VerticalMenu__collapseIndicator {
    transform: rotate(90deg);
  }
}
</style>
