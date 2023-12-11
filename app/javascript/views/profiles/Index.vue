<template>
  <div>
    <PageHeader :title="t('title')">
      <template v-slot:actions>
        <DropdownMenuItem
          :href="newProfilePath"
          :label="t('new')"
          icon="plus"
        />
      </template>
    </PageHeader>

    <ProfileShareInviteModal />

    <ProfileShareInvitesList />

    <ProfilesList :profiles="profiles" />
  </div>
</template>

<script>
import { profiles } from '~/api/all.js';
import I18n from '~/utils/I18n.js';

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

  setup() {
    const newProfilePath = profiles.new.path();

    return {
      newProfilePath,
      t: I18n.scopedTranslator('views.profiles.index'),
    };
  },
};
</script>
