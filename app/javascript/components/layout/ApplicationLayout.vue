<template>
  <div class="ApplicationLayout d-flex flex-column container-fluid px-0 background-curved-lines">
    <Navigation />
    <VerticalMenu />
    <ConfirmationModal />
    <TransactionForm />

    <div
      class="my-3 flex-shrink-0 flex-grow-1 d-flex flex-column"
      :class="{ 'container-xxl': !skipContainer, 'px-3': !skipContainer }"
    >
      <ToastNotifications />

      <slot />

      <FloatingActionButton v-if="!skipFloatingActionButton" />
    </div>

    <PageFooter />
  </div>
</template>

<script>
import { onMounted } from 'vue';
import { getQueryParams } from '~/utils/QueryStringUtils.js';
import useUserStore from '~/stores/UserStore.js';
import useNotificationStore from '~/stores/NotificationStore.js';
import useProfileStore from '~/stores/ProfileStore.js';
import useDateRangeStore from '~/stores/DateRangeStore.js';
import useTransactionStore from '~/stores/TransactionStore.js';
import { Modal as BootstrapModal } from 'bootstrap';
import { TRANSACTION_FORM_MODAL_ID } from '~/utils/Constants.js';

import ToastNotifications from '~/components/layout/ToastNotifications.vue';
import Navigation from '~/components/layout/Navigation.vue';
import PageFooter from '~/components/layout/PageFooter.vue';
import VerticalMenu from '~/components/layout/VerticalMenu.vue';
import FloatingActionButton from '~/components/layout/FloatingActionButton.vue';
import ConfirmationModal from '~/components/bootstrap/ConfirmationModal.vue';
import TransactionForm from '~/components/transactions/TransactionForm.vue';

export default {
  components: {
    ConfirmationModal,
    FloatingActionButton,
    Navigation,
    PageFooter,
    ToastNotifications,
    TransactionForm,
    VerticalMenu,
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
    skipContainer: {
      type: Boolean,
      default: false,
    },
    skipFloatingActionButton: {
      type: Boolean,
      default: false,
    },
    dateRange: {
      type: Object,
      default: () => {},
    },
  },
  setup(props) {
    const profileStore = useProfileStore();
    const dateRangeStore = useDateRangeStore();

    if (props.currentProfile) {
      /* eslint-disable-next-line vue/no-setup-props-destructure */
      profileStore.currentProfile = props.currentProfile;
    }

    if (props.availableProfiles) {
      /* eslint-disable-next-line vue/no-setup-props-destructure */
      profileStore.availableProfiles = props.availableProfiles;
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

    onMounted(() => {
      const queryParams = getQueryParams();
      if (queryParams['new_transaction']) {
        const transactionStore = useTransactionStore();
        transactionStore.setTransactionIdForFormModal(null);
        new BootstrapModal(`#${TRANSACTION_FORM_MODAL_ID}`).show();
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
