<template>
  <div class="btn-group">
    <button
      class="btn btn-sm ProfileSwitcher__button py-1 px-2 d-flex align-items-center flex-grow-0"
      :class="currentProfile ? 'btn-primary' : 'btn-warning'"
      type="button"
      data-bs-toggle="dropdown"
      aria-expanded="false"
      @click="handleDropDownClick"
    >
      <template v-if="currentProfile">
        <FontAwesomeIcon
          class="me-2"
          :icon="faIconForCurrency(currentProfile.currency)"
        />
        <span class="text-truncate">
          {{ currentProfile?.displayName }}
        </span>
      </template>
      <template v-else>
        {{ t('no_profile_selected') }}
      </template>
      <FontAwesomeIcon
        class="ms-2"
        icon="chevron-down"
      />
    </button>
    <ul class="dropdown-menu">
      <li
        v-for="profile in availableProfiles"
        :key="profile.id"
      >
        <a
          class="dropdown-item ProfileSwitcher__profile-link"
          :class="{ active: profile.id === currentProfile.id }"
          href="#"
          @click="handleProfileChange(profile.id)"
        >
          <FontAwesomeIcon
            class="ProfileSwitcher__currency-icon me-2 text-secondary"
            :icon="faIconForCurrency(profile.currency)"
          />

          <FontAwesomeIcon
            v-if="profile.shared"
            class="me-2 text-primary"
            icon="share-nodes"
          />

          {{ profile.displayName }}
        </a>
      </li>

      <li>
        <hr class="dropdown-divider my-2">
      </li>

      <li>
        <a
          class="dropdown-item"
          :href="newProfilePath"
        >
          <FontAwesomeIcon
            class="ProfileSwitcher__currency-icon me-2 text-secondary"
            icon="square-plus"
          />
          {{ t('new_profile_link') }}
        </a>
      </li>
    </ul>
  </div>
</template>

<script>
import { ref } from 'vue';
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';
import { storeToRefs } from 'pinia';

import useProfileStore from '~/stores/ProfileStore.js';
import useNotificationStore from '~/stores/NotificationStore.js';
import { profiles, currentProfiles } from '~/api/all.js';
import { faIconForCurrency } from '~/utils/CurrencyIcons.js';
import I18n from '~/utils/I18n.js';

export default {
  components: {
    FontAwesomeIcon,
  },

  setup() {
    const t = I18n.scopedTranslator('views.layout.profile_switcher');

    const profileStore = useProfileStore();
    const { currentProfile, availableProfiles } = storeToRefs(profileStore);
    const dropdownOpened = ref(false);
    const newProfilePath = profiles.new.path();

    const handleProfileChange = (profileId) => {
      currentProfiles
        .create({ data: { profile_id: profileId } })
        .then((response) => {
          if (response.error) {
            const { errorMessages } = storeToRefs(useNotificationStore());
              errorMessages.value.push(response.error);
          } else {
            currentProfile.value = response.profile;
          }
        });
    };

    const handleDropDownClick = (ev) => {
      dropdownOpened.value = ev.target.classList.contains('show');
    };

    return {
      availableProfiles,
      currentProfile,
      dropdownOpened,
      faIconForCurrency,
      handleProfileChange,
      handleDropDownClick,
      newProfilePath,
      t,
    };
  },
};
</script>

<style lang="scss" scoped>
@import '../../stylesheets/variables';

.ProfileSwitcher__button {
  min-width: 0;
}

.ProfileSwitcher__button svg:last-child {
  transition: all 0.25s;
  transform: rotate(0deg);
}

.ProfileSwitcher__button.show svg:last-child {
  transform: rotate(180deg);
}

.ProfileSwitcher__profile-link.active svg {
  color: $white !important;
}

.ProfileSwitcher__currency-icon {
  width: 2em;
}
</style>
