import { computed } from 'vue';

import {
  budgets as budgetsApi,
  categories as categoriesApi,
  dashboards as dashboardsApi,
  profiles as profilesApi,
  imports as importsApi,
  importsSettings as importsSettingsApi,
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
  ICON_BUDGETS,
  ICON_CATEGORIES,
  ICON_DASHBOARD,
  ICON_IMPORTS,
  ICON_IMPORT_LIST,
  ICON_IMPORT_SETTINGS,
  ICON_PROFILES,
  ICON_RECONCILIATIONS,
  ICON_SETTINGS,
  ICON_SIGN_IN,
  ICON_SIGN_OUT,
  ICON_SIGN_UP,
  ICON_TRANSACTION_AUTOMATIONS,
  ICON_TRANSACTION_LIST,
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
    expanded: isMenuItemExpanded(options),
    hasSubMenu: options.subItems && options.subItems.length > 0,
  });
};

const isMenuItemExpanded = (menuItem) => {
  if (menuItem.subItems && menuItem.subItems.length > 0) {
    return menuItem.subItems.some(subItem => isMenuItemActive(subItem.path));
  }
  return false;
}

export const isMenuItemActive = (itemPath) => {
  const currentPath = window.location.pathname;

  // Tries to match the exact path, or the following derivative paths:
  // Show page for a resource: /item-path/{uuid}
  // Edit page for a resource: /item-path/{uuid}/edit
  const pathRegex = new RegExp(`^${itemPath}(/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})?(/edit)?/?$`, 'i');
  return currentPath.match(pathRegex);
};

export const buildVerticalMenuItems = () => {
  const userStore = useUserStore();
  const isUserLoggedIn = computed(() => userStore.isUserLoggedIn);

  if (isUserLoggedIn.value) {
    return {
      top: [
        buildMenuItem({ key: 'dashboard', path: dashboardsApi.show.path(), icon: ICON_DASHBOARD }),
        buildMenuItem({
          key: 'transactions',
          path: '#collapse_transactions',
          icon: ICON_TRANSACTIONS,
          subItems: [
            buildMenuItem({ key: 'transactions_list', path: transactionsApi.index.path(), icon: ICON_TRANSACTION_LIST }),
            buildMenuItem({ key: 'transactions_automations', path: transactionAutomationsApi.index.path(), icon: ICON_TRANSACTION_AUTOMATIONS }),
            buildMenuItem({ key: 'transactions_predictions', path: transactionPredictionsApi.index.path(), icon: ICON_TRANSACTION_PREDICTIONS }),
          ]
        }),
        buildMenuItem({ key: 'reconciliations', path: reconciliationsApi.index.path(), icon: ICON_RECONCILIATIONS }),
        buildMenuItem({
          key: 'imports',
          path: '#collapse_imports',
          icon: ICON_IMPORTS,
          subItems: [
            buildMenuItem({ key: 'imports_list', path: importsApi.index.path(), icon: ICON_IMPORT_LIST }),
            buildMenuItem({ key: 'imports_settings', path: importsSettingsApi.show.path(), icon: ICON_IMPORT_SETTINGS }),
          ]
        }),
        buildMenuItem({ key: 'categories', path: categoriesApi.index.path(), icon: ICON_CATEGORIES }),
        buildMenuItem({ key: 'budgets', path: budgetsApi.index.path(), icon: ICON_BUDGETS }),
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
