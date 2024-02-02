<template>
  <div class="ProfilesList">
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

<style lang="scss" scoped>
@import '../../stylesheets/variables';

@include media-breakpoint-down(md) {
  .ProfilesList {
    margin-left: -1rem;
    margin-right: -1rem;
    width: calc(100% + 2rem);
  }
}
</style>
