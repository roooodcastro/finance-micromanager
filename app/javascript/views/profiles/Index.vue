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
      </template>
    </PageHeader>

    <ProfileShareInviteModal />

    <ProfileShareInvitesList />

    <ProfilesList />
  </div>
</template>

<script>
import I18n from '~/utils/I18n.js';
import useFloatingActionButtonStore from '~/stores/FloatingActionButtonStore.js';
import useProfileStore from '~/stores/ProfileStore.js';

import PageHeader from '~/components/layout/PageHeader.vue';
import ProfilesList from '~/components/profiles/ProfilesList.vue';
import ProfileShareInvitesList from '~/components/profile_share_invites/ProfileShareInvitesList.vue';
import ProfileShareInviteModal from '~/components/profile_share_invites/ProfileShareInviteModal.vue';
import DropdownMenuItem from '~/components/ui/DropdownMenuItem.vue';

export default {
  components: {
    PageHeader,
    DropdownMenuItem,
    ProfileShareInviteModal,
    ProfileShareInvitesList,
    ProfilesList,
  },

  props: {
    profiles: {
      type: Array,
      required: true,
    },
  },

  setup(props) {
    const profileStore = useProfileStore();
    profileStore.loadCollectionFromProps(props.profiles);

    const handleNew = () => profileStore.openFormModal(null);

    const floatingActionButtonStore = useFloatingActionButtonStore();
    floatingActionButtonStore.registerSpeedDialEntry({
      label: I18n.t('views.profiles.floating_button_label'),
      icon: 'wallet',
      callback: handleNew,
    });


    return {
      t: I18n.scopedTranslator('views.profiles.index'),
      handleNew,
    };
  },
};
</script>
