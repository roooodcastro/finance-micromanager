<template>
  <div class="card border-0">
    <PageHeader :page-title="t('title')" />

    <div class="card-header bg-primary border-0 py-4 d-flex flex-column align-items-center">
      <h3 class="mb-4 text-white">
        {{ t('title') }}
      </h3>

      <span class="ProfileShow__profile-photo d-flex justify-content-center align-items-center">
        <FontAwesomeIcon
          icon="user"
          size="3x"
        />
      </span>
    </div>

    <div class="card-body">
      <template v-if="inEditMode">
        edit
      </template>

      <template v-else>
        <ProfileListItem
          icon="user-tag"
          :value="user.firstName"
          :empty-label="t('empty_first_name_label')"
        />

        <ProfileListItem
          icon="user-tag"
          :value="user.lastName"
          :empty-label="t('empty_last_name_label')"
        />

        <ProfileListItem
          icon="at"
          :value="user.email"
        />

        <ProfileListItem
          icon="key"
          value="**********"
        />
      </template>
    </div>
  </div>
</template>

<script>
import { ref } from 'vue';
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';

import I18n from '@/utils/I18n';
import { profiles as profilesApi } from '~/api';

import PageHeader from '~/components/layout/PageHeader.vue';
import ProfileListItem from '~/components/profiles/ProfileListItem.vue';

export default {
  components: {
    FontAwesomeIcon,
    PageHeader,
    ProfileListItem,
  },

  props: {
    user: {
      type: Object,
      required: true,
    },
  },

  setup() {
    const inEditMode = ref(false);

    const updatePath = profilesApi.update.path();

    return {
      inEditMode,
      updatePath,
      t: I18n.scopedTranslator('views.profiles.show'),
    };
  }
};
</script>

<style lang="scss" scoped>
@import '../../stylesheets/variables';

.ProfileShow__profile-photo {
  background-color: $gray-200;
  border-radius: 50%;
  display: flex;
  width: 8rem;
  height: 8rem;

  svg {
    color: $gray-400;
    height: 70%;
  }
}
</style>
