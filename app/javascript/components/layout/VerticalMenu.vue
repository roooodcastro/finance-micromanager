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
          <FontAwesomeIcon
            :icon="menuItem.icon"
            class="me-4"
          />

          {{ menuItem.label }}
        </a>
      </div>
    </div>
  </div>
</template>

<script>
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';

import {
  accounts,
  categories,
  profiles as profilesApi,
  transactions,
  usersSessions,
  usersRegistrations
} from '~/api';
import I18n from '~/utils/I18n';

import useUserStore from '~/stores/UserStore.js';

export default {
  components: {
    FontAwesomeIcon,
  },

  setup() {
    const t = I18n.scopedTranslator('views.layout.vertical_menu')
    const userStore = useUserStore();
    let menuItems;

    if (userStore.isUserLoggedIn) {
      menuItems = [
        { label: t('profile'), path: profilesApi.get.path(), icon: 'user' },
        { label: t('dashboard'), path: transactions.list.path(), icon: 'list' },
        { label: t('categories'), path: categories.list.path(), icon: 'shapes' },
        { label: t('accounts'), path: accounts.list.path(), icon: 'wallet' },
        { label: t('sign_out'), path: usersSessions.destroy.path(), icon: 'right-from-bracket', method: 'DELETE' },
      ];
    } else {
      menuItems = [
        { label: t('sign_in'), path: usersSessions.new.path(), icon: 'right-to-bracket' },
        { label: t('sign_up'), path: usersRegistrations.new.path(), icon: 'user-plus' },
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
