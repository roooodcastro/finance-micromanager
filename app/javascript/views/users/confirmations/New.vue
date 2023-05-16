<template>
  <div>
    <Header page-title="Resend confirmation instructions" />

    <div class="card shadow">
      <div class="card-body py-4">
        <h4 class="card-title">
          Resend confirmation instructions
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
              label="Email Address"
              type="email"
              autocomplete="email"
              :value="prePopulatedEmail"
            />

            <div class="d-grid">
              <button
                type="submit"
                class="btn btn-primary"
              >
                Resend confirmation instructions
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
import { usersConfirmations } from '~/api';

import Header from '~/components/layout/Header.vue';
import RailsForm from '~/components/rails/RailsForm.vue';
import FormInputFloatingLabel from '~/components/rails/FormInputFloatingLabel.vue';
import DeviseLinks from '~/components/devise/DeviseLinks.vue';

export default {
  layout: 'LoginLayout',
  components: {
    DeviseLinks,
    FormInputFloatingLabel,
    Header,
    RailsForm,
  },

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
    };
  },
};
</script>
