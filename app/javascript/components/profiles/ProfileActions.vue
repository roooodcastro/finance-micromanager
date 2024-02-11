<template>
  <div class="vr mx-3 d-none d-lg-flex" />

  <a
    :class="{
      'd-flex align-items-center justify-content-center bg-info text-white': drawerMenu,
      'text-info': !drawerMenu,
    }"
    href="#"
    data-bs-toggle="modal"
    data-bs-target="#profileShareInviteModal"
    @click="handleProfileShareInviteModalClick(profile.id)"
  >
    <FontAwesomeIcon
      icon="share-nodes"
      size="lg"
    />
    <span class="d-none d-lg-inline-block ms-2">
      {{ t('share_action_link_label') }}
    </span>
  </a>

  <EditButton
    small
    href="#"
    :class="{
      'd-flex align-items-center justify-content-center bg-secondary text-white': drawerMenu,
      'ms-3': !drawerMenu,
    }"
    @click="handleEdit"
  />

  <DeleteButton
    small
    disable-label
    href="#"
    :class="{
      'd-flex align-items-center justify-content-center bg-danger text-white': drawerMenu,
      'ms-3': !drawerMenu,
    }"
    ask-confirmation
    @delete="handleDelete(profile.id)"
  />
</template>

<script>
import { profiles as profilesApi } from '~/api/all.js';
import I18n from '~/utils/I18n.js';
import useProfileStore from '~/stores/ProfileStore.js';
import useNotificationStore from '~/stores/NotificationStore.js';

import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';

import EditButton from '~/components/rails/EditButton.vue';
import DeleteButton from '~/components/rails/DeleteButton.vue';

export default {
  components: {
    DeleteButton,
    EditButton,
    FontAwesomeIcon,
  },

  props: {
    profile: {
      type: Object,
      required: true,
    },
    drawerMenu: {
      type: Boolean,
      default: false,
    },
  },

  setup(props) {
    const profileStore = useProfileStore();
    const notificationStore = useNotificationStore();

    const handleProfileShareInviteModalClick = profileId => profileStore.setProfileIdForInviteModal(profileId);

    const handleEdit = () => profileStore.openFormModal(props.profile.id);
    const handleDelete = (id) => {
      profilesApi.destroy({ id }).then((response) => {
        notificationStore.notify(response.message, 'success');
        profileStore.remove(response.profileId);
      });
    };

    return {
      t: I18n.scopedTranslator('views.profiles.index'),
      handleEdit,
      handleDelete,
      handleProfileShareInviteModalClick,
    };
  },
};
</script>

<style lang="scss" scoped>
.ProfileListItem__currency-icon {
  width: 2em;
}

.ProfileListItem:not(:first-child) {
  margin-top: -1px;
}
</style>
