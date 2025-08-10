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
          :action="registrationsPath"
          :errors="errors"
          method="POST"
          resource="user"
        >
          <template v-slot:default="{ formHelper }">
            <FormInputFloatingLabel
              :form-helper="formHelper"
              :value="user.email"
              field-name="email"
              :label="t('email_label')"
              type="email"
              autocomplete="email"
            />

            <FormInputFloatingLabel
              :form-helper="formHelper"
              field-name="password"
              :label="t('password_label')"
              type="password"
              autocomplete="new-password"
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
        <DeviseLinks page="registrations" />
      </div>
    </div>
  </div>
</template>

<script>
import { usersRegistrations } from '~/api/all.js';
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
    user: {
      type: Object,
      required: true,
    },
    errors: {
      type: Object,
      default: () => {},
    },
  },

  setup() {
    const registrationsPath = usersRegistrations.create.path();

    return {
      registrationsPath,
      t: I18n.scopedTranslator('views.users.registrations.new'),
    };
  },
};
</script>
