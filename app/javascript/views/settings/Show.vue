<template>
  <PageHeader :title="t('title')" />

  <PasswordChangeModal />

  <div class="card border-0">
    <div class="card-body border-0 py-4 py-lg-3 d-flex flex-column flex-lg-row align-items-center">
      <span class="ProfileShow__profile-photo d-flex justify-content-center align-items-center mb-4 mb-lg-0 me-lg-5">
        <FontAwesomeIcon
          icon="user"
          size="3x"
        />
      </span>

      <h3 class="mb-0 text-primary-emphasis">
        {{ userFromStore.fullName }}
      </h3>
    </div>
  </div>

  <RailsForm
    :action="updatePath"
    method="PATCH"
    resource="user"
    class="mx-1 mx-lg-0"
  >
    <template v-slot:default="{ formHelper }">
      <h4 class="mt-5">
        {{ t('header_profile_settings') }}
      </h4>
      <hr class="mb-4">

      <div class="d-grid gap-3 SettingsShow__form-grid mx-2 mx-lg-0">
        <FormInput
          v-model="userForForm.firstName"
          :label="t('first_name')"
          :form-helper="formHelper"
          field-name="first_name"
          autocomplete="given-name"
          :placeholder="t('empty_first_name_label')"
          class="rounded"
        />

        <FormInput
          v-model="userForForm.lastName"
          :label="t('last_name')"
          :form-helper="formHelper"
          field-name="last_name"
          autocomplete="family-name"
          :placeholder="t('empty_last_name_label')"
          class="rounded"
        />

        <FormInput
          v-model="userForForm.email"
          :label="t('email')"
          :form-helper="formHelper"
          field-name="email"
          type="email"
          autocomplete="email"
          class="rounded"
        />

        <div>
          <label
            :for="formHelper.fieldId('password')"
            class="form-label d-block"
          >
            {{ t('password') }}
          </label>

          <a
            :id="formHelper.fieldId('password')"
            href="#"
            class="d-block d-lg-inline-block btn btn-secondary"
            @click="handleChangePassword"
          >
            {{ t('change_password_button') }}
          </a>
        </div>
      </div>

      <h4 class="mt-5">
        {{ t('header_account_settings') }}
      </h4>
      <hr class="mb-4">

      <div class="d-grid gap-3 SettingsShow__form-grid mx-2 mx-lg-0">
        <div class="mb-3">
          <label
            :for="formHelper.fieldId('default_profile_id')"
            class="form-label"
          >
            {{ t('default_profile') }}
          </label>
          <ProfilesSelect
            :id="formHelper.fieldId('default_profile_id')"
            v-model="userForForm.defaultProfileId"
            :name="formHelper.fieldName('default_profile_id')"
          />
        </div>

        <div class="mb-3">
          <label
            :for="formHelper.fieldId('locale')"
            class="form-label"
          >
            {{ t('locale') }}
          </label>
          <LocalesSelect
            :id="formHelper.fieldId('locale')"
            v-model="userForForm.locale"
            :name="formHelper.fieldName('locale')"
          />
        </div>
      </div>


      <div>
        <hr class="mt-3 mt-lg-5 mb-4">

        <div class="d-grid d-lg-flex gap-2 SettingsShow__buttons-grid mx-2 mx-lg-0">
          <button
            type="submit"
            class="btn btn-primary"
            :disabled="!pendingChanges"
            @click.prevent="handleSubmit"
          >
            <FontAwesomeIcon
              icon="floppy-disk"
              size="lg"
              class="me-2"
            />

            {{ t('save_button') }}
          </button>

          <a
            href="#"
            class="btn btn-outline-secondary"
            :class="{ 'disabled': !pendingChanges }"
            @click="resetFormUser"
          >
            <FontAwesomeIcon
              icon="rotate-left"
              size="lg"
              class="me-2"
            />

            {{ t('reset_form_button') }}
          </a>
        </div>
      </div>
    </template>
  </RailsForm>
</template>

<script>
import { ref, computed } from 'vue';
import { storeToRefs } from 'pinia';
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';
import _ from 'lodash';

import I18n from '~/utils/I18n.js';
import { settings as settingsApi } from '~/api/all.js';
import { PASSWORD_CHANGE_MODAL_ID } from '~/utils/Constants.js';
import useUserStore from '~/stores/UserStore.js';
import useModalStore from '~/stores/ModalStore.js';

import PageHeader from '~/components/layout/PageHeader.vue';
import FormInput from '~/components/rails/FormInput.vue';
import RailsForm from '~/components/rails/RailsForm.vue';
import ProfilesSelect from '~/components/profiles/ProfilesSelect.vue';
import PasswordChangeModal from '~/components/user/PasswordChangeModal.vue';
import LocalesSelect from '~/components/forms/LocalesSelect.vue';

export default {
  components: {
    LocalesSelect,
    FormInput,
    FontAwesomeIcon,
    PageHeader,
    PasswordChangeModal,
    ProfilesSelect,
    RailsForm,
  },

  props: {
    user: {
      type: Object,
      required: true,
    },
  },

  setup(props) {
    const updatePath = settingsApi.update.path();
    const modalStore = useModalStore();
    const userStore = useUserStore();
    const { user: userFromStore } = storeToRefs(userStore);
    userFromStore.value = props.user;
    const userForForm = ref({ ...userFromStore.value });

    const resetFormUser = () => userForForm.value = { ...userFromStore.value };

    const pendingChanges = computed(() => !_.isEqual(userForForm.value, userFromStore.value));

    const handleSubmit = () => {
      const localeChanged = userForForm.value.locale !== userFromStore.value.locale;

      userStore.updateSettings(userForForm.value).then(() => {
        // Need to reload the page to reload and apply translations
        if (localeChanged) {
          window.location = window.location.pathname;
        }

        resetFormUser();
      });
    };

    const handleChangePassword = () => modalStore.show(PASSWORD_CHANGE_MODAL_ID);

    return {
      t: I18n.scopedTranslator('views.settings.show'),
      userFromStore,
      userForForm,
      pendingChanges,
      updatePath,
      resetFormUser,
      handleSubmit,
      handleChangePassword,
    };
  }
};
</script>

<style lang="scss" scoped>
@import '../../stylesheets/variables';

.ProfileShow__profile-photo {
  background-color: $gray-200;
  border: 3px solid $primary;
  border-radius: 50%;
  display: flex;
  width: 8rem;
  height: 8rem;

  svg {
    color: $gray-400;
    height: 70%;
  }
}

.SettingsShow__form-grid {
  grid-template-columns: repeat(2, 1fr);
}

.SettingsShow__buttons-grid {
  grid-template-columns: repeat(2, 1fr);
}

@include media-breakpoint-down(md) {
  .SettingsShow__form-grid {
    grid-template-columns: 1fr;
  }
}
</style>
