<template>
  <div>
    <PageHeader :title="t('title')">
      <template v-slot:actions>
        <DropdownMenuItem
          href="#"
          :label="t('new')"
          icon="plus"
          @click="handleNew"
        />

        <hr class="my-2">

        <DropdownMenuCheckItem
          :label="t('show_disabled')"
          :checked="showDisabled"
          @click="handleShowDisabled"
        />
      </template>
    </PageHeader>

    <ProfileShareInviteModal />

    <ProfileShareInvitesList />

    <ProfilesList />
  </div>
</template>

<script>
import { storeToRefs } from 'pinia';

import I18n from '~/utils/I18n.js';
import useFloatingActionButtonStore from '~/stores/FloatingActionButtonStore.js';
import useProfileStore from '~/stores/ProfileStore.js';
import { ICON_PROFILES, PROFILE_OPTIONS_COOKIE_NAME } from '~/utils/Constants.js';
import { getValueFromJsonCookie, setValueToJsonCookie } from '~/utils/CookieUtils.js';

import PageHeader from '~/components/layout/PageHeader.vue';
import ProfilesList from '~/components/profiles/ProfilesList.vue';
import ProfileShareInvitesList from '~/components/profile_share_invites/ProfileShareInvitesList.vue';
import ProfileShareInviteModal from '~/components/profile_share_invites/ProfileShareInviteModal.vue';
import DropdownMenuItem from '~/components/ui/DropdownMenuItem.vue';
import DropdownMenuCheckItem from '~/components/ui/DropdownMenuCheckItem.vue';

export default {
  components: {
    PageHeader,
    DropdownMenuCheckItem,
    DropdownMenuItem,
    ProfileShareInviteModal,
    ProfileShareInvitesList,
    ProfilesList,
  },

  setup() {
    const profileStore = useProfileStore();

    const { showDisabled } = storeToRefs(profileStore);

    const initialShowDisabled = !!getValueFromJsonCookie(PROFILE_OPTIONS_COOKIE_NAME, 'sd');
    profileStore.setFetchParams({ showDisabled: initialShowDisabled });
    profileStore.fetchCollection();

    const handleNew = () => profileStore.openFormModal(null);

    const handleShowDisabled = () => {
      profileStore.setFetchParams({ showDisabled: !showDisabled.value });
      setValueToJsonCookie(PROFILE_OPTIONS_COOKIE_NAME, 'sd', showDisabled.value);
      profileStore.fetchCollection();
    };

    const floatingActionButtonStore = useFloatingActionButtonStore();
    floatingActionButtonStore.registerSpeedDialEntry({
      label: I18n.t('views.profiles.floating_button_label'),
      icon: ICON_PROFILES,
      callback: handleNew,
      shortcut: { keys: 'alt+n', keyLabels: ['alt', 'n'] },
    });

    return {
      t: I18n.scopedTranslator('views.profiles.index'),
      showDisabled,
      handleNew,
      handleShowDisabled,
    };
  },
};
</script>
