<template>
  <RailsForm
    :action="formAction"
    :method="formMethod"
    resource="wallet"
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
            :value="wallet.name"
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
            :value="wallet.currency"
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
              :href="listWalletsPath"
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
import { wallets } from '~/api';
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
    wallet: {
      type: Object,
      required: true,
    },
  },

  setup(props) {
    const t = I18n.scopedTranslator('views.wallets.form');
    const listWalletsPath = wallets.index.path();

    const isNewRecord = !props.wallet.id;
    const formMethod = isNewRecord ? 'POST' : 'PATCH';
    const formAction = isNewRecord
      ? wallets.create.path()
      : wallets.update.path({ id: props.wallet.id });

    const formTitle = isNewRecord ? t('new_title') : t('edit_title', { wallet: props.wallet.displayName });

    return {
      formAction,
      formMethod,
      formTitle,
      listWalletsPath,
      t
    };
  },
};
</script>