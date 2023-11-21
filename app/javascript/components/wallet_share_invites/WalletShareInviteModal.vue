<template>
  <div
    id="walletShareInviteModal"
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
          v-if="walletForInviteModal"
          class="modal-body"
        >
          <InfoAlert
            v-if="walletForInviteModal.shared"
            :title="t('shared_warning_title')"
            :message="t('shared_warning_message', { name: walletForInviteModal.user.displayName })"
          />

          <RailsForm
            id="walletShareInvitForm"
            :action="walletShareInvitesPath"
            method="POST"
            resource="wallet_share_invite"
          >
            <template v-slot:default="{ formHelper }">
              <input
                :id="formHelper.fieldId('wallet_id')"
                :name="formHelper.fieldName('wallet_id')"
                :value="walletForInviteModal.id"
                type="hidden"
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
            form="walletShareInvitForm"
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
import { walletShareInvitesSent as walletShareInvitesSentApi } from '~/api';
import useWalletStore from '~/stores/WalletStore.js';

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
    const walletStore = useWalletStore();
    const { walletForInviteModal } = storeToRefs(walletStore);
    const walletShareInvitesPath = walletShareInvitesSentApi.create.path();

    return {
      t: I18n.scopedTranslator('views.wallet_share_invites.modal'),
      walletForInviteModal,
      walletShareInvitesPath,
    }
  },
};
</script>
