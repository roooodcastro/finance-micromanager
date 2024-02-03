<template>
  <FormModal
    :t="t"
    :record="profile"
    :form-id="PROFILE_FORM_ID"
    :modal-id="modalId"
    :loading="loading"
  >
    <template v-slot:default="{ closeModal }">
      <RailsForm
        :id="PROFILE_FORM_ID"
        :action="formAction"
        :method="formMethod"
        resource="profile"
        @submit.prevent="handleSubmit(closeModal)"
      >
        <template v-slot:default="{ formHelper }">
          <FormInput
            v-model="profile.name"
            field-name="name"
            :form-helper="formHelper"
            :label="t('name_label')"
            class="focus"
            maxlength="30"
          />

          <label
            :for="formHelper.fieldId('currency')"
            class="form-label"
          >
            {{ t('currency_label') }}
          </label>

          <InfoAlert
            :message="t('currency_change_warning')"
          />

          <CurrencySelect
            :id="formHelper.fieldId('currency')"
            v-model="profile.currency"
            :name="formHelper.fieldName('currency')"
            :disabled="!isNewRecord"
            required
          />

          <template v-if="!isNewRecord">
            <label
              :for="formHelper.fieldId('default_wallet_id')"
              class="form-label mt-3"
            >
              {{ t('default_wallet_label') }}
            </label>

            <WalletsSelect
              :id="formHelper.fieldId('default_wallet_id')"
              v-model="profile.defaultWalletId"
              :name="formHelper.fieldName('default_wallet_id')"
            />
          </template>
        </template>
      </RailsForm>
    </template>
  </FormModal>
</template>

<script>
import { computed, ref } from 'vue';
import { storeToRefs } from 'pinia';

import { profiles as profilesApi } from '~/api/all.js';
import I18n from '~/utils/I18n.js';
import { PROFILE_FORM_ID } from '~/utils/Constants.js';
import useModalStore from '~/stores/ModalStore.js';
import useProfileStore from '~/stores/ProfileStore.js';

import RailsForm from '~/components/rails/RailsForm.vue';
import FormModal from '~/components/forms/FormModal.vue';
import CurrencySelect from '~/components/currencies/CurrencySelect.vue';
import FormInput from '~/components/rails/FormInput.vue';
import WalletsSelect from '~/components/wallets/WalletsSelect.vue';
import InfoAlert from '~/components/bootstrap/InfoAlert.vue';

export default {
  components: {
    CurrencySelect,
    FormInput,
    FormModal,
    InfoAlert,
    RailsForm,
    WalletsSelect,
  },

  setup() {
    const t = I18n.scopedTranslator('views.profiles.form');

    const loading = ref(false);

    const modalStore = useModalStore();
    const modalId = modalStore.modalId(PROFILE_FORM_ID);

    const profileStore = useProfileStore();
    const { profileForFormModal: profile } = storeToRefs(profileStore);

    const isNewRecord = computed(() => !profile.value.id);
    const formMethod = isNewRecord.value ? 'POST' : 'PATCH';
    const formAction = isNewRecord.value
      ? profilesApi.create.path()
      : profilesApi.update.path({ id: profile.value.id });

    const handleSubmit = (closeModal) => {
      loading.value = true;

      if (isNewRecord.value) {
        profileStore
          .create(profile.value)
          .then(closeModal)
          .catch(() => {})
          .finally(() => loading.value = false);
      } else {
        profileStore
          .update(profile.value.id, profile.value)
          .then(closeModal)
          .catch(() => {})
          .finally(() => loading.value = false);
      }
    };

    return {
      t,
      loading,
      modalId,
      profile,
      formAction,
      formMethod,
      isNewRecord,
      handleSubmit,
      PROFILE_FORM_ID,
    };
  },
};
</script>
