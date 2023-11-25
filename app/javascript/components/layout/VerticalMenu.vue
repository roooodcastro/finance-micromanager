<template>
  <HorizontalSwipe
    id="verticalMenu"
    class="VerticalMenu offcanvas offcanvas-start"
    aria-labelledby="mainMenuLabel"
    :min-translation="minTranslation"
    :max-translation="0"
    :enabled="swipeActive"
    v-on="{ 'hide.bs.offcanvas': handleHide, 'shown.bs.offcanvas': handleShown }"
    @swipeleft="handleSwipeClose"
  >
    <div class="offcanvas-body px-0 pt-0">
      <MenuProfileSection v-if="isUserLoggedIn" />

      <div class="list-group">
        <a
          v-for="menuItem in menuItems"
          :key="menuItem.label"
          :href="menuItem.path"
          class="list-group-item list-group-item-action border-0"
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
  </HorizontalSwipe>
</template>

<script>
import { onMounted, ref } from 'vue';
import { Offcanvas as BootstrapOffcanvas } from 'bootstrap';
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';

import {
  wallets,
  categories,
  transactions as transactionsApi,
  dashboards as dashboardsApi,
  usersSessions,
  usersRegistrations
} from '~/api';
import I18n from '~/utils/I18n';

import useUserStore from '~/stores/UserStore.js';

import MenuProfileSection from '~/components/layout/MenuProfileSection.vue';
import HorizontalSwipe from '~/components/layout/HorizontalSwipe.vue';

export default {
  components: {
    HorizontalSwipe,
    FontAwesomeIcon,
    MenuProfileSection,
  },

  setup() {
    const t = I18n.scopedTranslator('views.layout.vertical_menu');
    const userStore = useUserStore();
    const isUserLoggedIn = userStore.isUserLoggedIn;
    let menuItems;

    if (userStore.isUserLoggedIn) {
      menuItems = [
        { label: t('dashboard'), path: dashboardsApi.show.path(), icon: 'list' },
        { label: t('transactions'), path: transactionsApi.index.path(), icon: 'list' },
        { label: t('categories'), path: categories.index.path(), icon: 'shapes' },
        { label: t('wallets'), path: wallets.index.path(), icon: 'wallet' },
        { label: t('sign_out'), path: usersSessions.destroy.path(), icon: 'right-from-bracket', method: 'DELETE' },
      ];
    } else {
      menuItems = [
        { label: t('sign_in'), path: usersSessions.new.path(), icon: 'right-to-bracket' },
        { label: t('sign_up'), path: usersRegistrations.new.path(), icon: 'user-plus' },
      ];
    }

    menuItems.forEach((menuItem) => {
      const currentPath = window.location.pathname;
      const menuPath = menuItem.path;

      if ((menuPath !== '/' && currentPath.includes(menuPath)) || (currentPath === '/' && menuPath === '/')) {
        menuItem['active'] = true;
      }
    });

    const offcanvas = ref(null);

    onMounted(() => {
      const offcanvasElement = document.querySelector('#verticalMenu');
      offcanvas.value = new BootstrapOffcanvas(offcanvasElement);
    });

    const minTranslation = ref(0);

    const setMinTranslation = () => {
      minTranslation.value = -document.querySelector('#verticalMenu').clientWidth;
    };

    onMounted(() => setMinTranslation());

    // Disable HorizontalSwipe so that Bootstrap's OffCanvas transition works
    const swipeActive = ref(false);
    const handleShown = () => swipeActive.value = true;
    const handleHide = () => swipeActive.value = false;

    const handleSwipeClose = () => {
      offcanvas.value.hide();

      // Trick to force the HorizontalSwipe to reset the transition value
      minTranslation.value = 0;
      setTimeout(setMinTranslation, 0);
    };

    return {
      t,
      menuItems,
      isUserLoggedIn,
      minTranslation,
      swipeActive,
      handleShown,
      handleHide,
      handleSwipeClose,
    };
  },
}
</script>

<style lang="scss" scoped>
@import '../../stylesheets/variables';

@include media-breakpoint-down(md) {
  .VerticalMenu {
    max-width: 80vw;
  }
}
</style>
