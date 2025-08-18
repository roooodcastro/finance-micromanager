<template>
  <div class="NavigationTabs d-lg-none position-fixed bottom-0 bg-primary w-100">
    <nav class="d-grid h-100 position-relative">
      <a
        :href="dashboardPath"
        class="btn btn-primary ps-2 pe-1 rounded-0"
        :class="{ 'active': isMenuItemActive(dashboardPath) }"
      >
        <FontAwesomeIcon
          :icon="ICON_DASHBOARD"
          size="xl"
        />
        <span>{{ t('home') }}</span>
      </a>

      <a
        :href="budgetsPath"
        class="d-none d-sm-flex btn btn-primary p-1 rounded-0"
        :class="{ 'active': isMenuItemActive(budgetsPath) }"
      >
        <FontAwesomeIcon
          :icon="ICON_BUDGETS"
          size="xl"
        />
        <span>{{ t('budgets') }}</span>
      </a>

      <a
        :href="transactionsPath"
        class="NavigationTabs__transactionsBtn btn btn-primary p-1 rounded-0"
        :class="{ 'active': isMenuItemActive(transactionsPath) }"
      >
        <FontAwesomeIcon
          :icon="ICON_TRANSACTIONS"
          size="xl"
        />
        <span>{{ t('transactions') }}</span>
      </a>

      <div class="d-flex justify-content-center">
        <FloatingActionButton />
      </div>

      <a
        :href="categoriesPath"
        class="NavigationTabs__categoriesBtn btn btn-primary p-1 rounded-0"
        :class="{ 'active': isMenuItemActive(categoriesPath) }"
      >
        <FontAwesomeIcon
          :icon="ICON_CATEGORIES"
          size="xl"
        />
        <span>{{ t('categories') }}</span>
      </a>

      <a
        :href="importsPath"
        class="d-none d-sm-flex btn btn-primary p-1 rounded-0"
        :class="{ 'active': isMenuItemActive(importsPath) }"
      >
        <FontAwesomeIcon
          :icon="ICON_IMPORTS"
          size="xl"
        />
        <span>{{ t('imports') }}</span>
      </a>

      <a
        :href="walletsPath"
        class="btn btn-primary ps-1 pe-2 rounded-0"
        :class="{ 'active': isMenuItemActive(walletsPath) }"
      >
        <FontAwesomeIcon
          :icon="ICON_WALLETS"
          size="xl"
        />
        <span>{{ t('wallets') }}</span>
      </a>
    </nav>
  </div>
</template>

<script>
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';

import {
  budgets as budgetsApi,
  categories as categoriesApi,
  dashboards as dashboardsApi,
  imports as importsApi,
  transactions as transactionsApi,
  wallets as walletsApi,
} from '~/api/all.js';

import {
  ICON_BUDGETS,
  ICON_CATEGORIES,
  ICON_DASHBOARD,
  ICON_IMPORTS,
  ICON_TRANSACTIONS,
  ICON_WALLETS,
} from '~/utils/Constants.js';

import I18n from '~/utils/I18n.js';
import { isMenuItemActive } from '~/utils/VerticalMenu.js';

import FloatingActionButton from '~/components/layout/FloatingActionButton.vue';

export default {
  components: {
    FloatingActionButton,
    FontAwesomeIcon,
  },

  setup() {
    const t = I18n.scopedTranslator('views.layout.vertical_menu');

    const budgetsPath = budgetsApi.index.path();
    const dashboardPath = dashboardsApi.show.path();
    const importsPath = importsApi.index.path();
    const transactionsPath = transactionsApi.index.path();
    const categoriesPath = categoriesApi.index.path();
    const walletsPath = walletsApi.index.path();

    return {
      t,
      budgetsPath,
      dashboardPath,
      importsPath,
      transactionsPath,
      categoriesPath,
      walletsPath,
      ICON_BUDGETS,
      ICON_CATEGORIES,
      ICON_DASHBOARD,
      ICON_IMPORTS,
      ICON_TRANSACTIONS,
      ICON_WALLETS,
      isMenuItemActive,
    };
  },
};
</script>

<style lang="scss" scoped>
@import '../../stylesheets/variables';

.NavigationTabs {
  box-shadow: 0 -0.25rem 0.5rem rgba($black, .15);
  height: $navigation-tabs-height;

  nav {
    grid-template-columns: repeat(5, minmax(0, 1fr));
    width: 100%;
  }

  nav > a {
    align-content: center;
    align-items: center;
    justify-content: center;
    display: flex;
    flex-direction: column;
    gap: 0.25rem;
    padding: 0;
    text-transform: none;
    width: 100%;

    span {
      font-size: 0.75rem;
      overflow: hidden;
      max-width: 100%;
      text-overflow: ellipsis;
      white-space: nowrap;
    }
  }
}

.NavigationTabs__transactionsBtn, .NavigationTabs__categoriesBtn {
  position: relative;
}

.NavigationTabs__transactionsBtn::before {
  content: '';
  background-color: transparent;
  border: var(--bs-btn-border-width) solid transparent;
  border-left: none;
  margin: -1px 0;
  position: absolute;
  top: 0;
  bottom: 0;
  left: 100%;
  width: 50%;
  transition: color 0.15s ease-in-out, background-color 0.15s ease-in-out, border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out;
}

.NavigationTabs__categoriesBtn::before {
  content: '';
  background-color: transparent;
  border: var(--bs-btn-border-width) solid transparent;
  border-right: none;
  margin: -1px 0;
  position: absolute;
  top: 0;
  bottom: 0;
  right: 100%;
  width: 50%;
  transition: color 0.15s ease-in-out, background-color 0.15s ease-in-out, border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out;
}

.NavigationTabs__transactionsBtn.active, .NavigationTabs__transactionsBtn:active, .NavigationTabs__transactionsBtn:hover, .NavigationTabs__transactionsBtn:focus {
  border-right-color: var(--bs-btn-active-border-color);

  &::before {
    color: var(--bs-btn-active-color);
    background-color: var(--bs-btn-active-bg);
    border-color: var(--bs-btn-active-border-color);
  }
}

.NavigationTabs__categoriesBtn.active, .NavigationTabs__categoriesBtn:active, .NavigationTabs__categoriesBtn:hover, .NavigationTabs__categoriesBtn:focus {
  border-left-color: var(--bs-btn-active-border-color);

  &::before {
    color: var(--bs-btn-active-color);
    background-color: var(--bs-btn-active-bg);
    border-color: var(--bs-btn-active-border-color);
  }
}

.NavigationTabs__transactionsBtn:hover {
  &:before {
    background-color: var(--bs-btn-hover-bg);
  }
}

.NavigationTabs__categoriesBtn:hover {
  &:before {
    background-color: var(--bs-btn-hover-bg);
  }
}

@include media-breakpoint-up(sm) {
  .NavigationTabs nav {
    grid-template-columns: repeat(7, minmax(0, 1fr));
  }
}
</style>
