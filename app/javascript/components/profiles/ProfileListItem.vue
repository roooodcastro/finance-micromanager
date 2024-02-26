<template>
  <ListItem
    :record="profile"
    :actions-component="ProfileActions"
  >
    <div class="d-flex align-items-center p-2">
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
    </div>
  </ListItem>
</template>

<script>
import { markRaw } from 'vue';
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';

import I18n from '~/utils/I18n.js';
import { faIconForCurrency } from '~/utils/CurrencyIcons.js';

import ProfileActions from '~/components/profiles/ProfileActions.vue';
import ListItem from '~/components/ui/ListItem.vue';

export default {
  components: {
    ListItem,
    FontAwesomeIcon,
  },

  props: {
    profile: {
      type: Object,
      required: true,
    },
  },

  setup() {
    markRaw(ProfileActions);

    return {
      t: I18n.scopedTranslator('views.profiles.index'),
      faIconForCurrency,
      ProfileActions,
    };
  },
};
</script>

<style lang="scss" scoped>
.ProfileListItem__currency-icon {
  width: 2em;
}
</style>
