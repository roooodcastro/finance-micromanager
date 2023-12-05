<template>
  <ListItemDrawerContextMenu class="mx-2 mx-lg-0">
    <template v-slot:actions>
      <ProfileActions
        :profile="profile"
        drawer-menu
      />
    </template>
    <template v-slot:item>
      <div class="ProfileListItem d-flex bg-light-subtle align-items-center border bg-white p-2">
        <FontAwesomeIcon
            size="lg"
            class="ProfileListItem__currency-icon text-secondary me-3"
            :icon="faIconForCurrency(profile.currency)"
        />

        <div class="flex-grow-1">
          {{ profile.name || t('no_name') }}
          <span class="d-block fs-6 text-muted">
            {{ profile.currencyObject.name }}
          </span>

          <div
              v-if="profile.shared"
              class="fs-6 text-muted"
          >
            <FontAwesomeIcon
                class=" text-primary me-2"
                icon="share-nodes"
            />
            {{ t('shared_text', { user: profile.user.fullName }) }}
          </div>
        </div>
        <div class="d-none d-lg-flex">
          <ProfileActions :profile="profile" />
        </div>
      </div>
    </template>
  </ListItemDrawerContextMenu>
</template>

<script>
import I18n from '~/utils/I18n.js';
import { faIconForCurrency } from '~/utils/CurrencyIcons.js';

import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';

import ListItemDrawerContextMenu from '~/components/layout/ListItemDrawerContextMenu.vue';
import ProfileActions from '~/components/profiles/ProfileActions.vue';

export default {
  components: {
    FontAwesomeIcon,
    ListItemDrawerContextMenu,
    ProfileActions,
  },

  props: {
    profile: {
      type: Object,
      required: true,
    },
  },

  setup() {
    return {
      faIconForCurrency,
      t: I18n.scopedTranslator('views.profiles.index'),
    };
  },
};
</script>

<style lang="scss" scoped>
.ProfileListItem__currency-icon {
  width: 2em;
}

.ProfileListItem:not(:first-child) {
  margin-top: -1px;
}
</style>
