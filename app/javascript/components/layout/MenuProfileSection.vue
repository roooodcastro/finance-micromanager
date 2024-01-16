<template>
  <div class="d-flex py-3 px-2 bg-light border-0 text-decoration-none align-items-center">
    <a
      class="text-decoration-none"
      :href="showSettingsPath"
    >
      <ProfileAvatar class="fs-1 mx-lg-3" />
    </a>

    <div class="MenuProfileSection__info ms-2 d-flex flex-column text-primary flex-grow-1">
      <div>
        {{ name || email }}
      </div>
      <div
        v-if="name"
        class="text-muted fs-6"
      >
        {{ email }}
      </div>

      <ProfileSwitcher
        class="mt-2"
      />
    </div>

    <CloseButton
      v-if="offcanvas"
      class="align-self-start me-1"
      dismiss="offcanvas"
    />
  </div>
</template>

<script>
import I18n from '~/utils/I18n.js';
import { storeToRefs } from 'pinia';

import useUserStore from '~/stores/UserStore.js';
import useProfileStore from '~/stores/ProfileStore.js';

import { settings as settingsApi } from '~/api/all.js';

import ProfileAvatar from '~/components/layout/ProfileAvatar.vue';
import CloseButton from '~/components/bootstrap/CloseButton.vue';
import ProfileSwitcher from '~/components/layout/ProfileSwitcher.vue';

export default {
  components: {
    CloseButton,
    ProfileAvatar,
    ProfileSwitcher,
  },

  props: {
    offcanvas: {
      type: Boolean,
      default: false,
    },
  },

  setup() {
    const profileStore = useProfileStore();
    const userStore = useUserStore();

    const { currentProfile } = storeToRefs(profileStore);
    const email = userStore.user.email;
    const name = userStore.user.fullName;
    const showSettingsPath = settingsApi.show.path();

    return {
      currentProfile,
      name,
      email,
      showSettingsPath,
      t: I18n.scopedTranslator('views.layout.vertical_menu'),
    };
  }
};
</script>

<style lang="scss" scoped>
.MenuProfileSection__info {
  min-width: 0;
}
</style>
