<template>
  <div class="ProfilesList list-group">
    <ProfileListItem
      v-for="profile in profiles"
      :key="profile.id"
      :profile="profile"
    />
  </div>
</template>

<script>
import { storeToRefs } from 'pinia';

import I18n from '~/utils/I18n.js';
import useProfileStore from '~/stores/ProfileStore.js';

import ProfileListItem from '~/components/profiles/ProfileListItem.vue';

export default {
  components: {
    ProfileListItem,
  },

  setup() {
    const profileStore = useProfileStore();

    const { profiles } = storeToRefs(profileStore);

    return {
      t: I18n.scopedTranslator('views.profiles.index'),
      profiles,
    };
  },
};
</script>
