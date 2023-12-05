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

          <hr />

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

          <CurrencySelect
            :id="formHelper.fieldId('currency')"
            :name="formHelper.fieldName('currency')"
            :value="profile.currency"
            required
          />
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
import { profiles } from '~/api';
import I18n from '~/utils/I18n';

import RailsForm from '~/components/rails/RailsForm.vue';
import CurrencySelect from '~/components/currencies/CurrencySelect.vue';
import FormInput from '~/components/rails/FormInput.vue';

export default {
  components: {
    CurrencySelect,
    FormInput,
    RailsForm,
  },

  props: {
    profile: {
      type: Object,
      required: true,
    },
  },

  setup(props) {
    const t = I18n.scopedTranslator('views.profiles.form');
    const listProfilesPath = profiles.index.path();

    const isNewRecord = !props.profile.id;
    const formMethod = isNewRecord ? 'POST' : 'PATCH';
    const formAction = isNewRecord
      ? profiles.create.path()
      : profiles.update.path({ id: props.profile.id });

    const formTitle = isNewRecord ? t('new_title') : t('edit_title', { profile: props.profile.displayName });

    return {
      formAction,
      formMethod,
      formTitle,
      listProfilesPath,
      t
    };
  },
};
</script>
