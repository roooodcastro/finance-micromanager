<template>
  <div
    id="accountShareInviteModal"
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
          v-if="accountForInviteModal"
          class="modal-body"
        >
          <InfoAlert
            v-if="accountForInviteModal.shared"
            :title="t('shared_warning_title')"
            :message="t('shared_warning_message', { name: accountForInviteModal.user.displayName })"
          />

          <RailsForm
            id="accountShareInvitForm"
            :action="accountShareInvitesPath"
            method="POST"
            resource="account_share_invite"
          >
            <template v-slot:default="{ formHelper }">
              <input
                type="hidden"
                :id="formHelper.fieldId('account_id')"
                :name="formHelper.fieldName('account_id')"
                :value="accountForInviteModal.id"
              />

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
            form="accountShareInvitForm"
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

import I18n from '~/utils/I18n';
import { accountShareInvites as accountShareInvitesApi } from '~/api';
import useAccountStore from '~/stores/AccountStore.js';

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
    const accountStore = useAccountStore();
    const { accountForInviteModal } = storeToRefs(accountStore);
    const accountShareInvitesPath = accountShareInvitesApi.create.path();

    return {
      t: I18n.scopedTranslator('views.account_share_invites.modal'),
      accountForInviteModal,
      accountShareInvitesPath,
    }
  },
};
</script>
