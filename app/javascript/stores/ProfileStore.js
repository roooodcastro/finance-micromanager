import profilesApi from '~/api/ProfilesApi.js';
import { PROFILE_FORM_ID } from '~/utils/Constants.js';
import { defineBaseApiStore } from '~/stores/BaseApiStore.js';
import useNotificationStore from '~/stores/NotificationStore.js';
import useModalStore from '~/stores/ModalStore.js';
import I18n from '~/utils/I18n.js';

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
    loading: false,
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
    showDisabled: state => state.fetchParams.showDisabled,
  },
  actions: {
    remove(id) {
      this.profiles = this.profiles.filter(profile => profile.id !== id);
    },

    setProfileIdForInviteModal(profileId) {
      this.profileIdForInviteModal = profileId;
    },

    disable(id) {
      const notificationStore = useNotificationStore();
      const modalStore = useModalStore();

      modalStore
        .showConfirmationDialog({ message: I18n.t('views.profiles.confirmation.disable') })
        .then(() => {
          profilesApi
            .destroy({ id })
            .then((response) => {
              this.fetchCollection();
              this.fetchSingle(id);
              notificationStore.notify(response.message, 'success');
            })
            .catch((error) => {
              const errorMessage = error?.body?.message ?? I18n.t('views.layout.rails.generic_error');
              notificationStore.notify(errorMessage, 'danger');
            });
        });
    },

    reenable(id, fetchOptions = {}) {
      const notificationStore = useNotificationStore();
      const modalStore = useModalStore();

      modalStore
        .showConfirmationDialog({ message: I18n.t('views.profiles.confirmation.reenable') })
        .then(() => {
          profilesApi
            .reenable({ id })
            .then((response) => {
              this.fetch(id, fetchOptions);
              notificationStore.notify(response.message, 'success');
            })
            .catch((error) => {
              const errorMessage = error?.body?.message ?? I18n.t('views.layout.rails.generic_error');
              notificationStore.notify(errorMessage, 'danger');
            });
        });
    },
  },
});
