<template>
  <div>
    <PageHeader :page-title="t('new_title')" />

    <div class="row justify-content-center">
      <div class="col col-md-8 col-lg-6 col-xl-4">
        <ProfileForm :profile="profile" />
      </div>
    </div>
  </div>
</template>

<script>
import { profiles } from '~/api/all.js';
import I18n from '~/utils/I18n.Js';

import PageHeader from '~/components/layout/PageHeader.vue';
import ProfileForm from '~/components/profiles/ProfileForm.vue';

export default {
  components: {
    ProfileForm,
    PageHeader,
  },

  props: {
    profile: {
      type: Object,
      required: true,
    },
  },

  setup() {
    const listProfilesPath = profiles.index.path();

    return {
      listProfilesPath,
      t: I18n.scopedTranslator('views.profiles.form'),
    };
  },
};
</script>
