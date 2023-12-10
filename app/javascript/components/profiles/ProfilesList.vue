<template>
  <div class="ProfilesList">
    <ProfileListItem
      v-for="profile in profilesFromStore"
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

  props: {
    profiles: {
      type: Array,
      required: true,
    },
  },

  setup(props) {
    const profileStore = useProfileStore();

    const { availableProfiles: profilesFromStore } = storeToRefs(profileStore);
    profilesFromStore.value = props.profiles;

    return {
      t: I18n.scopedTranslator('views.profiles.index'),
      profilesFromStore,
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
