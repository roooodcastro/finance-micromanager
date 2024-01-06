import { defineStore } from 'pinia'
import profilesApi from '~/api/ProfilesApi.js';

export default defineStore('profile', {
  state: () => ({
    currentProfile: {},
    availableProfiles: [],
    profileIdForInviteModal: null,
  }),
  getters: {
    profileForInviteModal: (state) => {
      return state.availableProfiles.find(profile => profile.id === state.profileIdForInviteModal);
    },
    profilesForSelect: (state) => {
      return state.availableProfiles.reduce((result, profile) => {
        result.push({ label: profile.displayName, value: profile.id });
        return result;
      }, []);
    },
  },
  actions: {
    fetchAvailableProfiles() {
      profilesApi.index().then((response) => {
        this.availableProfiles = response.profiles;
      });
    },
    remove(id) {
      this.availableProfiles = this.availableProfiles.filter(profile => profile.id !== id);
    },
    setProfileIdForInviteModal(profileId) {
      this.profileIdForInviteModal = profileId;
    },
  },
});
