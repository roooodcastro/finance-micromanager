<template>
  <LoadingOverlay :loading="loading">
    <NoRecordsFound
      v-if="!profiles.length"
      class="m-3"
    />

    <BCard
      v-else
      no-body
      class="p-2"
    >
      <GridTable
        :rows="profiles"
        :columns="tableColumns"
        :actions="tableActions"
        bordered
        rounded
      >
        <template v-slot:default="{ row: profile }">
          <ProfileTableRow :profile="profile" />
        </template>
      </GridTable>
    </BCard>
  </LoadingOverlay>
</template>

<script>
import { storeToRefs } from 'pinia';

import I18n from '~/utils/I18n.js';
import useProfileStore from '~/stores/ProfileStore.js';
import { editAction, reenableAction } from '~/utils/GridTableUtils.js';

import NoRecordsFound from '~/components/layout/NoRecordsFound.vue';
import LoadingOverlay from '~/components/layout/LoadingOverlay.vue';
import BCard from '~/components/bootstrap/BCard.vue';
import GridTable from '~/components/ui/GridTable.vue';
import ProfileTableRow from '~/components/profiles/ProfileTableRow.vue';

export default {
  components: {
    BCard,
    GridTable,
    LoadingOverlay,
    NoRecordsFound,
    ProfileTableRow,
  },

  setup() {
    const t = I18n.scopedTranslator('views.components.profiles_list');
    const profileStore = useProfileStore();

    const { currentProfile, profiles, loading } = storeToRefs(profileStore);

    const tableActions = [
      editAction(profileStore),
      {
        label: I18n.t('views.layout.grid_table.disable_action_label'),
        icon: 'ban',
        callback: row => profileStore.disable(row.id),
        variant: 'danger',
        show: row => !row.disabledAt && row.id !== currentProfile.value.id
      },
      reenableAction(profileStore),
      {
        label: t('share_action_link_label'),
        icon: 'share-nodes',
        callback: row => profileStore.openShareInviteModal(row.id),
        variant: 'info',
        show: row => !row.disabledAt
      },
    ];

    const tableColumns = [
      { label: t('name_label'), side: 'left' },
      { label: t('currency_label'), side: 'left' },
      { label: t('default_wallet_label'), side: 'right' },
      { label: t('shared_by_label'), side: 'right' },
    ];

    return {
      t,
      loading,
      profiles,
      tableActions,
      tableColumns,
    };
  },
};
</script>
