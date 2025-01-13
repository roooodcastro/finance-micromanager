<template>
  <div
    :id="PROFILE_SHARE_INVITE_MODAL_ID"
    class="modal fade"
    tabindex="-1"
    :aria-labelledby="t('title')"
    aria-hidden="true"
  >
    <div class="modal-dialog">
      <div class="modal-content">
        <div class="modal-header">
          <h5 class="modal-title">
            {{ t('title') }}
          </h5>
          <CloseButton dismiss="modal" />
        </div>
        <div
          v-if="profileForInviteModal"
          class="modal-body"
        >
          <InfoAlert
            v-if="profileForInviteModal.shared"
            :title="t('shared_warning_title')"
            :message="t('shared_warning_message', { name: profileForInviteModal.user.displayName })"
          />

          <RailsForm
            id="profileShareInvitForm"
            :action="profileShareInvitesPath"
            method="POST"
            resource="profile_share_invite"
          >
            <template v-slot:default="{ formHelper }">
              <input
                :id="formHelper.fieldId('profile_id')"
                :name="formHelper.fieldName('profile_id')"
                :value="profileForInviteModal.id"
                type="hidden"
              >

              <FormInput
                :label="t('invitee_email_label')"
                :form-helper="formHelper"
                :placeholder="t('invitee_email_placeholder')"
                field-name="invitee_email"
                type="email"
              />
            </template>
          </RailsForm>
        </div>
        <div class="modal-footer">
          <button
            type="button"
            class="btn btn-outline-secondary"
            data-bs-dismiss="modal"
          >
            {{ t('cancel') }}
          </button>
          <button
            type="submit"
            form="profileShareInvitForm"
            class="btn btn-primary"
          >
            {{ t('confirm') }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { storeToRefs } from 'pinia';

import I18n from '~/utils/I18n.js';
import { profileShareInvitesSent as profileShareInvitesSentApi } from '~/api/all.js';
import { PROFILE_SHARE_INVITE_MODAL_ID } from '~/utils/Constants.js';
import useProfileStore from '~/stores/ProfileStore.js';

import CloseButton from '~/components/bootstrap/CloseButton.vue';
import InfoAlert from '~/components/bootstrap/InfoAlert.vue';
import RailsForm from '~/components/rails/RailsForm.vue';
import FormInput from '~/components/rails/FormInput.vue';

export default {
  components: {
    CloseButton,
    FormInput,
    InfoAlert,
    RailsForm,
  },

  setup() {
    const profileStore = useProfileStore();
    const { profileForInviteModal } = storeToRefs(profileStore);
    const profileShareInvitesPath = profileShareInvitesSentApi.create.path();

    return {
      t: I18n.scopedTranslator('views.profile_share_invites.modal'),
      profileForInviteModal,
      profileShareInvitesPath,
      PROFILE_SHARE_INVITE_MODAL_ID,
    }
  },
};
</script>
