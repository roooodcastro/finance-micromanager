<template>
  <div class="card border-0 ProfileShow">
    <PageHeader :page-title="t('title')" />

    <div class="card-header bg-primary border-0 py-4 py-lg-3 d-flex flex-column flex-lg-row align-items-center justify-content-center">
      <span class="ProfileShow__profile-photo d-flex justify-content-center align-items-center mb-4 mb-lg-0 me-lg-5">
        <FontAwesomeIcon
          icon="user"
          size="3x"
        />
      </span>

      <h3 class="mb-0 text-white">
        {{ t('title') }}
      </h3>
    </div>

    <div class="card-body container-xxl">
      <template v-if="inEditMode">
        <ProfileForm
          :user="user"
          @cancel="handleEditButtonClick"
        />
      </template>

      <template v-else>
        <ProfileListItem
          icon="user-tag"
          :value="user.firstName"
          :label="t('first_name')"
          :empty-label="t('empty_first_name_label')"
        />

        <ProfileListItem
          icon="user-tag"
          :value="user.lastName"
          :label="t('last_name')"
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

        <ProfileListItem
          icon="wallet"
          :value="user.defaultAccount?.displayName"
          :label="t('default_account')"
          :empty-label="t('empty_default_account_label')"
        />

        <div class="d-grid gap-2 d-md-flex">
          <a
            href="#"
            class="btn btn-primary mt-4"
            @click="handleEditButtonClick"
          >
            <FontAwesomeIcon
              icon="pen-to-square"
              class="me-3"
            />
            {{ t('edit_button') }}
          </a>
        </div>
      </template>
    </div>
  </div>
</template>

<script>
import { ref } from 'vue';
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';

import I18n from '~/utils/I18n';
import { profiles as profilesApi } from '~/api';

import PageHeader from '~/components/layout/PageHeader.vue';
import ProfileListItem from '~/components/profiles/ProfileListItem.vue';
import ProfileForm from '~/components/profiles/ProfileForm.vue';

export default {
  components: {
    FontAwesomeIcon,
    PageHeader,
    ProfileForm,
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
    const handleEditButtonClick = () => inEditMode.value = !inEditMode.value;

    const updatePath = profilesApi.update.path();

    return {
      handleEditButtonClick,
      inEditMode,
      updatePath,
      t: I18n.scopedTranslator('views.profiles.show'),
    };
  }
};
</script>

<style lang="scss" scoped>
@import '../../stylesheets/variables';

.ProfileShow {
  margin-top: -1rem;
}

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
