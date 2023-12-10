<template>
  <div>
    <PageHeader :page-title="t('title')" />

    <div class="card shadow">
      <div class="card-body py-4">
        <h4 class="card-title">
          {{ t('title') }}
        </h4>

        <RailsForm
          :action="passwordsPath"
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
        <DeviseLinks page="passwords" />
      </div>
    </div>
  </div>
</template>

<script>
import { usersPasswords } from '~/api/all.js';
import I18n from '~/utils/I18n.Js';

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

  setup() {
    const passwordsPath = usersPasswords.create.path();

    return {
      passwordsPath,
      t: I18n.scopedTranslator('views.users.passwords.new'),
    };
  },
};
</script>
