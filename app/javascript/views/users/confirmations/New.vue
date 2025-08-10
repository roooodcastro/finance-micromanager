<template>
  <div>
    <PageHeader
      :page-title="t('title')"
      hide-back-button
    />

    <div class="card shadow">
      <div class="card-body py-4">
        <h4 class="card-title">
          {{ t('title') }}
        </h4>

        <RailsForm
          :action="confirmationsPath"
          method="POST"
          resource="user"
        >
          <template v-slot:default="{ formHelper }">
            <FormInputFloatingLabel
              :form-helper="formHelper"
              field-name="email"
              :label="t('email_label')"
              type="email"
              autocomplete="email"
              :value="prePopulatedEmail"
            />

            <div class="d-grid">
              <button
                type="submit"
                class="btn btn-primary"
              >
                {{ t('submit') }}
              </button>
            </div>
          </template>
        </RailsForm>
      </div>

      <div class="card-footer py-4">
        <DeviseLinks page="confirmations" />
      </div>
    </div>
  </div>
</template>

<script>
import { usersConfirmations } from '~/api/all.js';
import I18n from '~/utils/I18n.js';

import PageHeader from '~/components/layout/PageHeader.vue';
import RailsForm from '~/components/rails/RailsForm.vue';
import FormInputFloatingLabel from '~/components/rails/FormInputFloatingLabel.vue';
import DeviseLinks from '~/components/devise/DeviseLinks.vue';

export default {
  components: {
    DeviseLinks,
    FormInputFloatingLabel,
    PageHeader,
    RailsForm,
  },

  layout: 'LoginLayout',

  props: {
    prePopulatedEmail: {
      type: String,
      default: null,
    },
  },

  setup() {
    const confirmationsPath = usersConfirmations.create.path();

    return {
      confirmationsPath,
      t: I18n.scopedTranslator('views.users.confirmations.new'),
    };
  },
};
</script>
