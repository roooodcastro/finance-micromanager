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

import {
  ICON_CATEGORIES,
  ICON_DASHBOARD,
  ICON_IMPORTS,
  ICON_PROFILES,
  ICON_RECONCILIATIONS,
  ICON_SETTINGS,
  ICON_SIGN_IN,
  ICON_SIGN_OUT,
  ICON_SIGN_UP,
  ICON_TRANSACTION_AUTOMATIONS,
  ICON_TRANSACTION_PREDICTIONS,
  ICON_TRANSACTIONS,
  ICON_WALLETS,
} from '~/utils/Constants.js';

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
        buildMenuItem({ key: 'dashboard', path: dashboardsApi.show.path(), icon: ICON_DASHBOARD }),
        buildMenuItem({ key: 'transactions', path: transactionsApi.index.path(), icon: ICON_TRANSACTIONS }),
        buildMenuItem({ key: 'transaction_automations', path: transactionAutomationsApi.index.path(), icon: ICON_TRANSACTION_AUTOMATIONS }),
        buildMenuItem({ key: 'transaction_predictions', path: transactionPredictionsApi.index.path(), icon: ICON_TRANSACTION_PREDICTIONS }),
        buildMenuItem({ key: 'reconciliations', path: reconciliationsApi.index.path(), icon: ICON_RECONCILIATIONS }),
        buildMenuItem({ key: 'imports', path: importsApi.index.path(), icon: ICON_IMPORTS }),
        buildMenuItem({ key: 'categories', path: categoriesApi.index.path(), icon: ICON_CATEGORIES }),
        buildMenuItem({ key: 'wallets', path: walletsApi.index.path(), icon: ICON_WALLETS }),
        buildMenuItem({ key: 'profiles', path: profilesApi.index.path(), icon: ICON_PROFILES }),
        buildMenuItem({ key: 'settings', path: settingsApi.show.path(), icon: ICON_SETTINGS }),
      ],
      bottom: [
        buildMenuItem({ key: 'sign_out', path: userSessionsApi.destroy.path(), icon: ICON_SIGN_OUT, method: 'DELETE' }),
      ],
    }
  } else {
    return {
      top: [],
      bottom: [
        buildMenuItem({ key: 'sign_in', path: userSessionsApi.new.path(), icon: ICON_SIGN_IN }),
        buildMenuItem({ key: 'sign_up', path: usersRegistrationsApi.new.path(), icon: ICON_SIGN_UP }),
      ],
    }
  }
};
