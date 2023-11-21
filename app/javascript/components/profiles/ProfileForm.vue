<template>
  <RailsForm
    :action="formAction"
    method="PATCH"
    resource="user"
  >
    <template v-slot:default="{ formHelper }">
      <div class="row border-bottom py-3 align-items-center">
        <FontAwesomeIcon
          icon="user-tag"
          size="3x"
          class="col-2 col-lg-1 icon-secondary"
        />

        <div class="col">
          <FormInputFloatingLabel
            :form-helper="formHelper"
            field-name="first_name"
            container-margin=""
            :label="t('first_name_label')"
            :value="user.firstName"
            class="ProfileForm__input"
          />
        </div>
      </div>

      <div class="row border-bottom py-3 align-items-center">
        <FontAwesomeIcon
          icon="user-tag"
          size="3x"
          class="col-2 col-lg-1 icon-secondary"
        />

        <div class="col">
          <FormInputFloatingLabel
            :form-helper="formHelper"
            field-name="last_name"
            container-margin=""
            :label="t('last_name_label')"
            :value="user.lastName"
            class="ProfileForm__input"
          />
        </div>
      </div>

      <div class="row border-bottom py-3 align-items-center">
        <FontAwesomeIcon
          icon="at"
          size="3x"
          class="col-2 col-lg-1 icon-secondary"
        />

        <div class="col">
          <FormInputFloatingLabel
            :form-helper="formHelper"
            field-name="email"
            container-margin=""
            :label="t('email_label')"
            :value="user.email"
            class="ProfileForm__input"
          />
        </div>
      </div>

      <div class="row border-bottom py-3 align-items-center">
        <FontAwesomeIcon
          icon="key"
          size="3x"
          class="col-2 col-lg-1 icon-secondary"
        />

        <div class="col ProfileForm__input">
          <a
            :href="changePasswordPath"
            class="btn btn-secondary my-1"
          >
            {{ t('update_password_link_label') }}
          </a>
        </div>
      </div>

      <div class="row border-bottom py-3 align-items-center">
        <FontAwesomeIcon
          icon="wallet"
          size="3x"
          class="col-2 col-lg-1 icon-secondary"
        />

        <div class="col">
          <label>
            {{ t('default_wallet_label') }}
          </label>
          <select
            :id="formHelper.fieldId('default_wallet_id')"
            :name="formHelper.fieldName('default_wallet_id')"
            class="form-select"
          >
          <option
            v-for="wallet in availableWallets"
            :key="wallet.id"
            :value="wallet.id"
            :selected="user.defaultWalletId === wallet.id"
          >
            {{ wallet.displayName }}
          </option>
          </select>
        </div>
      </div>

      <div class="d-grid gap-2 d-md-flex">
        <a
          href="#"
          class="btn btn-outline-secondary mt-4"
          @click="$emit('cancel')"
        >
          <FontAwesomeIcon
            icon="chevron-left"
            class="me-3"
          />
          {{ t('cancel_edit_button') }}
        </a>

        <button
          type="submit"
          class="btn btn-primary mt-4"
        >
          <FontAwesomeIcon
            icon="floppy-disk"
            class="me-3"
          />
          {{ t('submit') }}
        </button>
      </div>
    </template>
  </RailsForm>
</template>

<script>
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';
import { storeToRefs } from 'pinia';

import I18n from '~/utils/I18n';
import { profiles as profilesApi, usersPasswords as usersPasswordsApi } from '~/api';
import useWalletStore from '~/stores/WalletStore.js';

import RailsForm from '~/components/rails/RailsForm.vue';
import FormInputFloatingLabel from '~/components/rails/FormInputFloatingLabel.vue';

export default {
  components: {
    FontAwesomeIcon,
    FormInputFloatingLabel,
    RailsForm,
  },

  props: {
    user: {
      type: Object,
      required: true,
    },
  },

  emits: ['cancel'],

  setup() {
    const formAction = profilesApi.update.path();
    const changePasswordPath = usersPasswordsApi.edit.path();
    const walletStore = useWalletStore();
    const { availableWallets } = storeToRefs(walletStore);

    return {
      availableWallets,
      formAction,
      changePasswordPath,
      t: I18n.scopedTranslator('views.profiles.form')
    };
  }
};
</script>

<style lang="scss" scoped>
.ProfileForm__input {
  margin: -1px 0;
}
</style>
