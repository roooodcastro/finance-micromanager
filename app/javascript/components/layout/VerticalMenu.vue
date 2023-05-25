<template>
  <div
    id="verticalMenu"
    class="offcanvas offcanvas-start"
    aria-labelledby="mainMenuLabel"
  >
    <div class="offcanvas-header">
      <h5
        id="mainMenuLabel"
        class="offcanvas-title"
      >
        {{ t('title') }}
      </h5>
      <button
        type="button"
        class="btn-close"
        data-bs-dismiss="offcanvas"
        aria-label="{{ t('close') }}"
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
import { accounts, categories, transactions, usersSessions, usersRegistrations } from '~/api';
import I18n from '~/utils/I18n';

import useUserStore from '~/stores/UserStore.js';

export default {
  setup() {
    const t = I18n.scopedTranslator('views.vertical_menu')
    const userStore = useUserStore();
    let menuItems;

    if (userStore.isUserLoggedIn) {
      menuItems = [
        { label: t('dashboard'), path: transactions.list.path() },
        { label: t('categories'), path: categories.list.path() },
        { label: t('accounts'), path: accounts.list.path() },
        { label: t('sign_out'), path: usersSessions.destroy.path(), method: 'DELETE' },
      ];
    } else {
      menuItems = [
        { label: t('sign_in'), path: usersSessions.new.path() },
        { label: t('sign_up'), path: usersRegistrations.new.path() },
      ];
    }

    menuItems.forEach((menuItem) => {
      if (window.location.pathname.includes(menuItem.path)) {
        menuItem['active'] = true;
      }
    })

    return {
      menuItems,
      t,
    };
  },
}
</script>
