<template>
  <div
    class="offcanvas offcanvas-start"
    id="verticalMenu"
    aria-labelledby="mainMenuLabel"
  >
    <div class="offcanvas-header">
      <h5
        class="offcanvas-title"
        id="mainMenuLabel"
      >
        Main Menu
      </h5>
      <button
        type="button"
        class="btn-close"
        data-bs-dismiss="offcanvas"
        aria-label="Close"
      />
    </div>
    <div class="offcanvas-body px-0">
      <div class="list-group">
        <a
          v-for="menuItem in menuItems"
          :key="menuItem.label"
          :href="menuItem.path"
          class="list-group-item list-group-item-action"
          :class="{ active: menuItem.active }"
          :data-method="menuItem.method || 'GET'"
        >
          {{ menuItem.label }}
        </a>
      </div>
    </div>
  </div>
</template>

<script>
import { accounts, categories, transactions, usersSessions } from '~/api';

import useUserStore from '~/stores/UserStore.js';

export default {
  setup() {
    const userStore = useUserStore();
    let menuItems;

    if (userStore.isUserLoggedIn) {
      menuItems = [
        { label: 'Dashboard', path: transactions.list.path() },
        { label: 'Categories', path: categories.list.path() },
        { label: 'Accounts', path: accounts.list.path() },
        { label: 'Sign Out', path: usersSessions.destroy.path(), method: 'DELETE' },
      ];
    } else {
      menuItems = [{ label: 'Sign In', path: usersSessions.new.path() }];
    }

    menuItems.forEach((menuItem) => {
      if (window.location.pathname.includes(menuItem.path)) {
        menuItem['active'] = true;
      }
    })

    return {
      menuItems,
    };
  },
}
</script>
