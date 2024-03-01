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
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';

import {
  categories as categoriesApi,
  dashboards as dashboardsApi,
  profiles as profilesApi,
  reconciliations as reconciliationsApi,
  settings as settingsApi,
  transactionAutomations as transactionAutomationsApi,
  transactionPredictions as transactionPredictionsApi,
  transactions as transactionsApi,
  usersSessions as userSessionsApi,
  usersRegistrations as usersRegistrationsApi,
  wallets as walletsApi,
} from '~/api/all.js';
import I18n from '~/utils/I18n.js';

import useUserStore from '~/stores/UserStore.js';

import MenuProfileSection from '~/components/layout/MenuProfileSection.vue';
import {
  ICON_CATEGORIES, ICON_DASHBOARD,
  ICON_PROFILES, ICON_RECONCILIATIONS,
  ICON_SETTINGS,
  ICON_SIGN_IN,
  ICON_SIGN_OUT,
  ICON_SIGN_UP, ICON_TRANSACTION_AUTOMATIONS, ICON_TRANSACTION_PREDICTIONS, ICON_TRANSACTIONS,
  ICON_WALLETS,
} from '~/utils/Constants.js';

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
    const t = I18n.scopedTranslator('views.layout.vertical_menu');
    const userStore = useUserStore();
    const isUserLoggedIn = userStore.isUserLoggedIn;
    let menuItems;

    if (userStore.isUserLoggedIn) {
      menuItems = {
        top: [
          { label: t('dashboard'), path: dashboardsApi.show.path(), icon: ICON_DASHBOARD },
          { label: t('transactions'), path: transactionsApi.index.path(), icon: ICON_TRANSACTIONS },
          { label: t('transaction_automations'), path: transactionAutomationsApi.index.path(), icon: ICON_TRANSACTION_AUTOMATIONS },
          { label: t('transaction_predictions'), path: transactionPredictionsApi.index.path(), icon: ICON_TRANSACTION_PREDICTIONS },
          { label: t('reconciliations'), path: reconciliationsApi.index.path(), icon: ICON_RECONCILIATIONS },
          { label: t('categories'), path: categoriesApi.index.path(), icon: ICON_CATEGORIES },
          { label: t('wallets'), path: walletsApi.index.path(), icon: ICON_WALLETS },
          { label: t('profiles'), path: profilesApi.index.path(), icon: ICON_PROFILES },
          { label: t('settings'), path: settingsApi.show.path(), icon: ICON_SETTINGS },
        ],
        bottom: [
          { label: t('sign_out'), path: userSessionsApi.destroy.path(), icon: ICON_SIGN_OUT, method: 'DELETE' },
        ],
      };
    } else {
      menuItems = {
        top: [],
        bottom: [
          { label: t('sign_in'), path: userSessionsApi.new.path(), icon: ICON_SIGN_IN },
          { label: t('sign_up'), path: usersRegistrationsApi.new.path(), icon: ICON_SIGN_UP },
        ],
      };
    }

    const setActiveMenuItem = (menuItem) => {
      const currentPath = window.location.pathname;
      const menuPath = menuItem.path;

      if ((menuPath !== '/' && currentPath.includes(menuPath)) || (currentPath === '/' && menuPath === '/')) {
        menuItem['active'] = true;
      }
    };

    menuItems.top.forEach(setActiveMenuItem);
    menuItems.bottom.forEach(setActiveMenuItem);

    return {
      t,
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
