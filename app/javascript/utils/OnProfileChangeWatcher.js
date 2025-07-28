import { watch } from 'vue';
import { storeToRefs } from 'pinia';

import useProfileStore from '~/stores/ProfileStore.js';

export function onProfileChanged(callback) {
  const profileStore = useProfileStore();
  const { currentProfile } = storeToRefs(profileStore);
  watch(currentProfile, callback);
}

export function onProfileChangedRedirectToIndex(api) {
  const profileStore = useProfileStore();
  const { currentProfile } = storeToRefs(profileStore);
  watch(currentProfile, () => {
    window.location.href = api.index.path();
  });
}
