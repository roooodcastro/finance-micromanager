import { computed } from 'vue';

import {
  categories as categoriesApi,
  dashboards as dashboardsApi,
  profiles as profilesApi,
  imports as importsApi,
  reconciliations as reconciliationsApi,
  settings as settingsApi,
  transactionAutomations as transactionAutomationsApi,
  transactionPredictions as transactionPredictionsApi,
  transactions as transactionsApi,
  usersRegistrations as usersRegistrationsApi,
  usersSessions as userSessionsApi,
  wallets as walletsApi,
} from '~/api/all.js';

import I18n from '~/utils/I18n.js';
import useUserStore from '~/stores/UserStore.js';

const buildMenuItem = (options) => {
  return Object.assign(options, {
    label: I18n.t(`views.layout.vertical_menu.${options.key}`),
    active: isMenuItemActive(options.path),
  });
};

const isMenuItemActive = (path) => {
  const currentPath = window.location.pathname;

  if (currentPath === '/' && path === '/') {
    return true;
  }

  return path !== '/' && currentPath.includes(path);
};

export const buildVerticalMenuItems = () => {
  const userStore = useUserStore();
  const isUserLoggedIn = computed(() => userStore.isUserLoggedIn);

  if (isUserLoggedIn.value) {
    return {
      top: [
        buildMenuItem({ key: 'dashboard', path: dashboardsApi.show.path(), icon: 'home' }),
        buildMenuItem({ key: 'transactions', path: transactionsApi.index.path(), icon: 'list' }),
        buildMenuItem({ key: 'transaction_automations', path: transactionAutomationsApi.index.path(), icon: 'robot' }),
        buildMenuItem({ key: 'transaction_predictions', path: transactionPredictionsApi.index.path(), icon: 'wand-magic-sparkles' }),
        buildMenuItem({ key: 'reconciliations', path: reconciliationsApi.index.path(), icon: 'scale-balanced' }),
        buildMenuItem({ key: 'imports', path: importsApi.index.path(), icon: 'cloud-arrow-up' }),
        buildMenuItem({ key: 'categories', path: categoriesApi.index.path(), icon: ['far', 'folder'] }),
        buildMenuItem({ key: 'wallets', path: walletsApi.index.path(), icon: ['far', 'credit-card'] }),
        buildMenuItem({ key: 'profiles', path: profilesApi.index.path(), icon: 'wallet' }),
        buildMenuItem({ key: 'settings', path: settingsApi.show.path(), icon: 'sliders' }),
      ],
      bottom: [
        buildMenuItem({ key: 'sign_out', path: userSessionsApi.destroy.path(), icon: 'right-from-bracket', method: 'DELETE' }),
      ],
    }
  } else {
    return {
      top: [],
      bottom: [
        buildMenuItem({ key: 'sign_in', path: userSessionsApi.new.path(), icon: 'right-to-bracket' }),
        buildMenuItem({ key: 'sign_up', path: usersRegistrationsApi.new.path(), icon: 'user-plus' }),
      ],
    }
  }
};
