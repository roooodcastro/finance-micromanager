<template>
  <div
    :id="PASSWORD_CHANGE_MODAL_ID"
    class="modal fade"
    tabindex="-1"
    :aria-labelledby="t('title')"
    aria-hidden="true"
  >
    <div class="modal-dialog">
      <div class="modal-content">
        <div class="modal-header">
          <h5 class="modal-title">
            {{ t('modal_title') }}
          </h5>
          <CloseButton dismiss="modal" />
        </div>
        <div class="modal-body">
          <RailsForm
            :id="PASSWORD_CHANGE_FORM_ID"
            :action="updatePasswordPath"
            method="PATCH"
            resource="user"
          >
            <template v-slot:default="{ formHelper }">
              <FormInput
                :label="t('current_password_label')"
                :form-helper="formHelper"
                :placeholder="t('current_password_placeholder')"
                field-name="current_password"
                type="password"
                autocomplete="current-password"
                required
              />

              <FormInput
                v-model="newPassword"
                :label="t('new_password_label')"
                :form-helper="formHelper"
                :placeholder="t('new_password_placeholder')"
                field-name="password"
                type="password"
                autocomplete="new-password"
                required
              />

              <FormInput
                v-model="passwordConfirmation"
                :label="t('password_confirmation_label')"
                :form-helper="formHelper"
                :placeholder="t('password_confirmation_placeholder')"
                field-name="password_confirmation"
                type="password"
                autocomplete="new-password"
                required
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
            :form="PASSWORD_CHANGE_FORM_ID"
            class="btn btn-primary"
            @click.prevent="handleSubmit"
          >
            {{ t('modal_submit') }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { onMounted, ref } from 'vue';

import I18n from '~/utils/I18n.js';
import { usersRegistrations as usersRegistrationsApi } from '~/api/all.js';
import { PASSWORD_CHANGE_MODAL_ID, PASSWORD_CHANGE_FORM_ID } from '~/utils/Constants.js';
import useModalStore from '~/stores/ModalStore.js';
import useNotificationStore from '~/stores/NotificationStore.js';

import CloseButton from '~/components/bootstrap/CloseButton.vue';
import RailsForm from '~/components/rails/RailsForm.vue';
import FormInput from '~/components/rails/FormInput.vue';

export default {
  components: {
    CloseButton,
    FormInput,
    RailsForm,
  },

  setup() {
    const t = I18n.scopedTranslator('views.users.passwords.new');
    const updatePasswordPath = usersRegistrationsApi.update.path();

    const newPassword = ref(null);
    const passwordConfirmation = ref(null);

    const modalStore = useModalStore();
    const notificationStore = useNotificationStore();
    onMounted(() => modalStore.registerModal(PASSWORD_CHANGE_MODAL_ID));

    const handleSubmit = (ev) => {
      if (newPassword.value === passwordConfirmation.value) {
        ev.target.form.submit();
      } else {
        notificationStore.notify('Passwords must match!', 'danger');
      }
    };

    return {
      t,
      updatePasswordPath,
      newPassword,
      passwordConfirmation,
      handleSubmit,
      PASSWORD_CHANGE_MODAL_ID,
      PASSWORD_CHANGE_FORM_ID,
    }
  },
};
</script>
