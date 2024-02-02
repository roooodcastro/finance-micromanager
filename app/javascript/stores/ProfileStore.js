import profilesApi from '~/api/ProfilesApi.js';
import { PROFILE_FORM_ID } from '~/utils/Constants.js';
import { defineBaseApiStore } from '~/stores/BaseApiStore.js';

export default defineBaseApiStore('profile', {
  resourceName: 'profile',
  resourcesName: 'profiles',
  formId: PROFILE_FORM_ID,
  api: profilesApi,

  state: {
    currentProfile: {},
    profiles: [],
    idForFormModal: null,
    fetchParams: {},
    profileIdForInviteModal: null,
  },

  getters: {
    profileForInviteModal: (state) => {
      return state.profiles.find(profile => profile.id === state.profileIdForInviteModal);
    },
    profilesForSelect: (state) => {
      return state.profiles.reduce((result, profile) => {
        result.push({ label: profile.displayName, value: profile.id });
        return result;
      }, []);
    },
  },
  actions: {
    remove(id) {
      this.profiles = this.profiles.filter(profile => profile.id !== id);
    },
    setProfileIdForInviteModal(profileId) {
      this.profileIdForInviteModal = profileId;
    },
  },
});
