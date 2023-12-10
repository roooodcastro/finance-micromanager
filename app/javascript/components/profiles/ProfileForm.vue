<template>
  <RailsForm
    :action="formAction"
    :method="formMethod"
    resource="profile"
  >
    <template v-slot:default="{ formHelper }">
      <div class="card">
        <div class="card-body">
          <h4 class="card-title">
            {{ formTitle }}
          </h4>

          <hr>

          <FormInput
            field-name="name"
            :form-helper="formHelper"
            :value="profile.name"
            :label="t('name_label')"
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
            :name="formHelper.fieldName('currency')"
            :value="profile.currency"
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
              :value="profile.defaultWalletId"
              :name="formHelper.fieldName('default_wallet_id')"
            />
          </template>
        </div>

        <div class="card-footer">
          <div class="d-grid gap-2 d-md-flex">
            <button
              type="submit"
              class="btn btn-primary flex-md-fill"
            >
              {{ t('submit') }}
            </button>

            <a
              :href="listProfilesPath"
              class="btn btn-outline-secondary flex-md-fill"
            >
              {{ t('back') }}
            </a>
          </div>
        </div>
      </div>
    </template>
  </RailsForm>
</template>

<script>
import { computed } from 'vue';

import { profiles as profilesApi } from '~/api/all.js';
import I18n from '~/utils/I18n.Js';

import RailsForm from '~/components/rails/RailsForm.vue';
import CurrencySelect from '~/components/currencies/CurrencySelect.vue';
import FormInput from '~/components/rails/FormInput.vue';
import WalletsSelect from '~/components/wallets/WalletsSelect.vue';
import InfoAlert from '@/components/bootstrap/InfoAlert.vue';

export default {
  components: {
    InfoAlert,
    CurrencySelect,
    FormInput,
    RailsForm,
    WalletsSelect,
  },

  props: {
    profile: {
      type: Object,
      required: true,
    },
  },

  setup(props) {
    const t = I18n.scopedTranslator('views.profiles.form');

    const listProfilesPath = profilesApi.index.path();

    const isNewRecord = computed(() => !props.profile.id);
    const formMethod = isNewRecord.value ? 'POST' : 'PATCH';
    const formAction = isNewRecord.value
      ? profilesApi.create.path()
      : profilesApi.update.path({ id: props.profile.id });

    const formTitle = isNewRecord.value ? t('new_title') : t('edit_title', { profile: props.profile.displayName });

    return {
      formAction,
      formMethod,
      formTitle,
      isNewRecord,
      listProfilesPath,
      t
    };
  },
};
</script>
