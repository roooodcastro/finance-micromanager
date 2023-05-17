<template>
  <div>
    <PageHeader page-title="Sign Up" />

    <div class="card shadow">
      <div class="card-body py-4">
        <h4 class="card-title">
          Sign Up
        </h4>

        <RailsForm
          :action="signUpPath"
          method="POST"
          resource="user"
        >
          <template v-slot:default="{ formHelper }">
            <FormInputFloatingLabel
              :form-helper="formHelper"
              field-name="email"
              label="Email Address"
              type="email"
              autocomplete="email"
            />

            <FormInputFloatingLabel
              :form-helper="formHelper"
              field-name="password"
              label="Choose a Password"
              type="password"
              autocomplete="new-password"
            />

            <div class="d-grid">
              <button
                type="submit"
                class="btn btn-primary"
              >
                Submit
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
import { usersRegistrations } from '~/api';

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
    const registrationsPath = usersRegistrations.create.path();

    return {
      registrationsPath,
    };
  },
};
</script>
