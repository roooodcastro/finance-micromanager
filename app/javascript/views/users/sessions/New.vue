<template>
  <div>
    <PageHeader :page-title="t('title')" />

    <div class="card shadow">
      <div class="card-body py-4">
        <h4 class="card-title">
          {{ t('title') }}
        </h4>

        <RailsForm
          :action="sessionsPath"
          method="POST"
          resource="user"
        >
          <template v-slot:default="{ formHelper }">
            <FormInputFloatingLabel
              :form-helper="formHelper"
              :value="email"
              field-name="email"
              :label="t('email_label')"
              type="email"
              autocomplete="email"
            />

            <FormInputFloatingLabel
              :form-helper="formHelper"
              :value="password"
              field-name="password"
              :label="t('password_label')"
              type="password"
              autocomplete="current-password"
            />

            <div class="form-check form-switch py-2 mb-3">
              <input
                :id="formHelper.fieldId('remember_me')"
                :name="formHelper.fieldName('remember_me')"
                class="form-check-input"
                type="checkbox"
                value="true"
              />
              <label
                class="form-check-label ms-2"
                :for="formHelper.fieldId('remember_me')"
              >
                {{ t('remember_me_label') }}
              </label>
            </div>

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
        <DeviseLinks page="sessions" />
      </div>
    </div>

    <PageFooter compact />
  </div>
</template>

<script>
import { usersSessions } from '~/api';
import I18n from '~/utils/I18n.js';

import PageHeader from '~/components/layout/PageHeader.vue';
import RailsForm from '~/components/rails/RailsForm.vue';
import FormInputFloatingLabel from '~/components/rails/FormInputFloatingLabel.vue';
import DeviseLinks from '~/components/devise/DeviseLinks.vue';
import PageFooter from '~/components/layout/PageFooter.vue';

export default {
  components: {
    DeviseLinks,
    PageFooter,
    FormInputFloatingLabel,
    PageHeader,
    RailsForm,
  },

  layout: 'LoginLayout',

  props: {
    email: {
      type: String,
      default: '',
    },
    password: {
      type: String,
      default: '',
    },
  },

  setup() {
    const sessionsPath = usersSessions.create.path();

    return {
      sessionsPath,
      t: I18n.scopedTranslator('views.users.sessions.new'),
    };
  },
};
</script>
