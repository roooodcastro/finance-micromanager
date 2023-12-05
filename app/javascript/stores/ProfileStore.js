import { defineStore } from 'pinia'
import profilesApi from '~/api/ProfilesApi';

export default defineStore('profile', {
  state: () => ({
    currentProfile: {},
    availableProfiles: [],
    profileIdForInviteModal: null,
  }),
  getters: {
    profileForInviteModal: (state) => {
      return state.availableProfiles.find(profile => profile.id === state.profileIdForInviteModal);
    }
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
