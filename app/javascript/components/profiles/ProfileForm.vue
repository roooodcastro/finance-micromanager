<template>
  <RailsForm
    :action="formAction"
    method="PATCH"
    resource="profile"
  >
  </RailsForm>
</template>

<script>
import I18n from '@/utils/I18n';
import { profiles as profilesApi } from '~/api';

import RailsForm from '~/components/rails/RailsForm.vue';

export default {
  components: {
    RailsForm,
  },

  setup() {
    const formAction = profilesApi.update.path();

    return {
      formAction,
      t: I18n.scopedTranslator('views.profiles.form')
    };
  }
};
</script>
