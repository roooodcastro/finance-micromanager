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
    <div class="offcanvas-body px-0 pt-0 d-flex flex-column">
      <MenuProfileSection v-if="isUserLoggedIn" />

      <div class="d-flex flex-column justify-content-between flex-grow-1 mt-3">
        <div class="list-group">
          <a
            v-for="menuItem in menuItems.top"
            :key="menuItem.label"
            :href="menuItem.path"
            class="VerticalMenu__item-link list-group-item list-group-item-action border-0"
            :class="{ active: menuItem.active }"
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
            class="VerticalMenu__item-link list-group-item list-group-item-action border-0"
            :class="{ active: menuItem.active }"
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
  </HorizontalSwipe>
</template>

<script>
import { onMounted, ref } from 'vue';
import { Offcanvas as BootstrapOffcanvas } from 'bootstrap';
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';

import {
  categories as categoriesApi,
  dashboards as dashboardsApi,
  profiles as profilesApi,
  reconciliations as reconciliationsApi,
  transactions as transactionsApi,
  usersSessions as userSessionsApi,
  usersRegistrations as usersRegistrationsApi,
  wallets as walletsApi,
} from '~/api/all.js';
import I18n from '~/utils/I18n.js';

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
      menuItems = {
        top: [
          { label: t('dashboard'), path: dashboardsApi.show.path(), icon: 'home' },
          { label: t('transactions'), path: transactionsApi.index.path(), icon: 'list' },
          { label: t('reconciliations'), path: reconciliationsApi.index.path(), icon: 'scale-balanced' },
          { label: t('categories'), path: categoriesApi.index.path(), icon: ['far', 'folder'] },
          { label: t('profiles'), path: profilesApi.index.path(), icon: 'wallet' },
          { label: t('wallets'), path: walletsApi.index.path(), icon: ['far', 'credit-card'] },
        ],
        bottom: [
          { label: t('sign_out'), path: userSessionsApi.destroy.path(), icon: 'right-from-bracket', method: 'DELETE' },
        ],
      };
    } else {
      menuItems = {
        top: [],
        bottom: [
          { label: t('sign_in'), path: userSessionsApi.new.path(), icon: 'right-to-bracket' },
          { label: t('sign_up'), path: usersRegistrationsApi.new.path(), icon: 'user-plus' },
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

.VerticalMenu__item-link {
  span {
    display: inline-block;
    transition: transform 0.1s linear;
  }
  svg {
    transition: transform 0.1s linear;
    width: 2rem;
  }

  &:hover, &:active, &:focus, &.active {
    svg {
      transform: scale(1.25);
    }
    span {
      transform: translateX(0.5rem);
    }
  }
}

@include media-breakpoint-down(md) {
  .VerticalMenu {
    max-width: 80vw;
  }
}
</style>
