<template>
  <div>
    <Header page-title="Sign Up" />

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
            <FormInput
              :form-helper="formHelper"
              field-name="email"
              label="Email Address"
              type="email"
              autocomplete="email"
            />

            <FormInput
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
        <div class="d-grid gap-3">
          <a
            :href="loginPath"
            class="btn btn-light btn-sm"
          >
            Sign In
          </a>

          <a
            href="#"
            class="btn btn-light btn-sm"
          >
            Didn't receive confirmation instructions?
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
import FormInput from '~/components/rails/FormInput.vue';

export default {
  layout: 'LoginLayout',
  components: {
    FormInput,
    Header,
    RailsForm,
  },

  setup() {
    const signUpPath = usersRegistrations.create.path();
    const loginPath = usersSessions.new.path();

    return {
      loginPath,
      signUpPath,
    };
  },
};
</script>
