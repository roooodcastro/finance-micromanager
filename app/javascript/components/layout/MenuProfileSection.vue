<template>
  <div class="MenuProfileSection d-flex py-1 px-2 text-decoration-none align-items-center">
    <a
      class="text-decoration-none"
      :href="showProfilePath"
    >
      <ProfileAvatar />
    </a>

    <div class="ms-2 d-flex flex-column text-primary">
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
  </div>
</template>

<script>
import { storeToRefs } from 'pinia';

import useUserStore from '~/stores/UserStore.js';
import useAccountStore from '~/stores/AccountStore.js';

import { profiles as profilesApi } from '~/api';

import ProfileAvatar from "~/components/layout/ProfileAvatar.vue";
import AccountLabel from "~/components/accounts/AccountLabel.vue";
import I18n from "~/utils/I18n";

export default {
  components: {
    AccountLabel,
    ProfileAvatar,
  },

  setup() {
    const accountStore = useAccountStore();
    const userStore = useUserStore();

    const { currentAccount } = storeToRefs(accountStore);
    const email = userStore.user.email;
    const name = userStore.fullName;
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

<style lang="scss" scoped>
@import '../../stylesheets/variables';

.aMenuProfileSection {
  cursor: pointer;

  &:hover {
    background-color: $gray-100;
  }
}
</style>
