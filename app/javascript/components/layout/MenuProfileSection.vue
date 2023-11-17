<template>
  <div class="d-flex py-3 px-2 bg-light border-0 text-decoration-none align-items-center">
    <a
      class="text-decoration-none"
      :href="showProfilePath"
    >
      <ProfileAvatar />
    </a>

    <div class="ms-2 d-flex flex-column text-primary flex-grow-1">
      <div>
        {{ name || email }}
      </div>
      <div
        v-if="name"
        class="text-muted fs-6"
      >
        {{ email }}
      </div>
      <div class="d-flex flex-row">
        {{ t('current_account') }}
        <AccountLabel
          class="ms-2"
          :account="currentAccount"
        />
      </div>
    </div>

    <CloseButton
      class="align-self-start me-1"
      dismiss="offcanvas"
    />
  </div>
</template>

<script>
import { storeToRefs } from 'pinia';

import useUserStore from '~/stores/UserStore.js';
import useAccountStore from '~/stores/AccountStore.js';

import { profiles as profilesApi } from '~/api';

import ProfileAvatar from "~/components/layout/ProfileAvatar.vue";
import AccountLabel from "~/components/accounts/AccountLabel.vue";
import CloseButton from "~/components/bootstrap/CloseButton.vue";
import I18n from "~/utils/I18n";

export default {
  components: {
    AccountLabel,
    CloseButton,
    ProfileAvatar,
  },

  setup() {
    const accountStore = useAccountStore();
    const userStore = useUserStore();

    const { currentAccount } = storeToRefs(accountStore);
    const email = userStore.user.email;
    const name = userStore.user.fullName;
    const showProfilePath = profilesApi.show.path();

    return {
      currentAccount,
      name,
      email,
      showProfilePath,
      t: I18n.scopedTranslator('views.layout.vertical_menu'),
    };
  }
};
</script>
