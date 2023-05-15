<template>
  <div>
    <Header page-title="Login" />

    <div class="card shadow">
      <div class="card-body py-4">
        <h4 class="card-title">
          Login
        </h4>

        <RailsForm
          :action="sessionsPath"
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
              label="Password"
              type="password"
              autocomplete="password"
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
        <div class="d-grid gap-3">
          <a
            :href="newRegistrationPath"
            class="btn btn-light btn-sm"
          >
            Sign Up
          </a>

          <a
            href="#"
            class="btn btn-light btn-sm"
          >
            Forgot your password?
          </a>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { usersSessions, usersRegistrations } from '~/api';

import Header from '~/components/layout/Header.vue';
import RailsForm from '~/components/rails/RailsForm.vue';
import FormInputFloatingLabel from '~/components/rails/FormInputFloatingLabel.vue';

export default {
  layout: 'LoginLayout',
  components: {
    FormInputFloatingLabel,
    Header,
    RailsForm,
  },

  setup() {
    const sessionsPath = usersSessions.create.path();
    const newRegistrationPath = usersRegistrations.new.path();

    return {
      sessionsPath,
      newRegistrationPath,
    };
  },
};
</script>
