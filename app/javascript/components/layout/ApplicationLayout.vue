<template>
  <div class="ApplicationLayout d-flex flex-column container-fluid px-0">
    <Navigation />

    <div class="d-flex container-fluid flex-grow-1 px-0 px-lg-3">
      <VerticalMenu class="d-none d-xxl-block flex-shrink-0 me-3" />

      <div class="mb-3 my-lg-3 flex-grow-1 min-width-0 d-flex flex-column">
        <ToastNotifications />

        <div class="min-width-0 flex-grow-1">
          <slot />
        </div>

        <FloatingActionButton />
      </div>
    </div>

    <PageFooter />
    <VerticalMenuOffcanvas />
    <ConfirmationModal />
    <ShortcutHelpModal />
    <TransactionForm />
    <ProfileForm />
  </div>
</template>

<script>
import { onMounted } from 'vue';
import { getQueryParams } from '~/utils/QueryStringUtils.js';
import I18n from '~/utils/I18n.js';
import useUserStore from '~/stores/UserStore.js';
import useNotificationStore from '~/stores/NotificationStore.js';
import useProfileStore from '~/stores/ProfileStore.js';
import useDateRangeStore from '~/stores/DateRangeStore.js';
import useTransactionStore from '~/stores/TransactionStore.js';
import useFloatingActionButtonStore from '~/stores/FloatingActionButtonStore.js';
import useBrowserCacheStore from '~/stores/BrowserCacheStore.js';
import useLocaleStore from '~/stores/LocaleStore.js';
import useModalStore from '~/stores/ModalStore.js';
import useShortcutStore from '~/stores/ShortcutStore.js';
import { ICON_TRANSACTIONS, SHORTCUTS_HELP_MODAL_ID } from '~/utils/Constants.js';

import ToastNotifications from '~/components/layout/ToastNotifications.vue';
import Navigation from '~/components/layout/Navigation.vue';
import PageFooter from '~/components/layout/PageFooter.vue';
import VerticalMenu from '~/components/layout/VerticalMenu.vue';
import VerticalMenuOffcanvas from '~/components/layout/VerticalMenuOffcanvas.vue';
import FloatingActionButton from '~/components/layout/FloatingActionButton.vue';
import ConfirmationModal from '~/components/bootstrap/ConfirmationModal.vue';
import TransactionForm from '~/components/transactions/TransactionForm.vue';
import ProfileForm from '~/components/profiles/ProfileForm.vue';
import ShortcutHelpModal from '~/components/ui/ShortcutHelpModal.vue';

export default {
  components: {
    ConfirmationModal,
    FloatingActionButton,
    Navigation,
    PageFooter,
    ProfileForm,
    ShortcutHelpModal,
    ToastNotifications,
    TransactionForm,
    VerticalMenu,
    VerticalMenuOffcanvas,
  },
  props: {
    notifications: {
      type: Object,
      required: true,
    },
    user: {
      type: Object,
      required: true,
    },
    currentProfile: {
      type: Object,
      required: true,
    },
    availableProfiles: {
      type: Object,
      required: true,
    },
    dateRange: {
      type: Object,
      default: () => {},
    },
  },
  setup(props) {
    const modalStore = useModalStore();
    const localeStore = useLocaleStore();
    const shortcutStore = useShortcutStore();
    const profileStore = useProfileStore();
    const dateRangeStore = useDateRangeStore();
    const transactionStore = useTransactionStore();
    const browserCacheStore = useBrowserCacheStore();
    const floatingActionButtonStore = useFloatingActionButtonStore();

    browserCacheStore.loadFromPageLoad();
    localeStore.fetchCollection();

    floatingActionButtonStore.registerSpeedDialEntry({
      label: I18n.t('views.transactions.floating_button_label'),
      icon: ICON_TRANSACTIONS,
      callback: () => transactionStore.openFormModal(null),
    });

    if (props.currentProfile) {
      /* eslint-disable-next-line vue/no-setup-props-destructure */
      profileStore.currentProfile = props.currentProfile;
    }

    if (props.availableProfiles) {
      /* eslint-disable-next-line vue/no-setup-props-destructure */
      profileStore.profiles = props.availableProfiles;
    }

    if (props.user) {
      const userStore = useUserStore();

      /* eslint-disable-next-line vue/no-setup-props-destructure */
      userStore.user = props.user;
    }

    if (props.notifications) {
      useNotificationStore().loadFromProps(props.notifications);
    }

    if (props.dateRange.startDate) {
      dateRangeStore.setFromProps(props.dateRange);
    }

    shortcutStore.registerShortcut('shift+/', 'help', ['?'], (event) => {
      const targetTagName = (event.target || event.srcElement).tagName;
      // Do not trigger when focused element is an editable input
      if (!/^(INPUT|TEXTAREA|SELECT)$/.test(targetTagName)) {
        modalStore.show(SHORTCUTS_HELP_MODAL_ID);
      }
    });

    onMounted(() => {
      const queryParams = getQueryParams();
      if (queryParams['new_transaction']) {
        transactionStore.openFormModal(null);
      }
    })
  },
};
</script>

<style lang="scss" scoped>
.ApplicationLayout {
  min-height: 100%;
}
</style>
