<template>
  <PageHeader
    :sub-title="t('title')"
    :back-button-href="profilesPath"
  >
    <div class="d-flex gap-3 align-items-center justify-content-between me-3">
      {{ profileFromStore.name }}
      <Badge
        v-if="isDisabled"
        type="disabled"
        class="fs-6"
      />
    </div>
    <template v-slot:actions>
      <DropdownMenuItem
        :label="t('edit')"
        icon="pen-to-square"
        @click="handleEdit"
      />

      <DropdownMenuItem
        v-if="!isDisabled"
        :label="t('disable')"
        icon="ban"
        class="text-bg-danger"
        @click="handleDisable"
      />
      <DropdownMenuItem
        v-else
        :label="t('reenable')"
        icon="repeat"
        class="text-bg-success"
        @click="handleReenable"
      />
    </template>
  </PageHeader>

  <TabRowContainer
    :tabs="tabsConfig"
    no-card-when-expanded
  >
    <template v-slot:summary="{ isTabLayout }">
      <BCard
        :title="isTabLayout ? '' : t('sub_header_summary')"
        class="h-100"
      >
        <template v-slot:header>
          <button
            class="btn btn-context-action rounded-circle gap-5"
            @click="handleEdit"
          >
            <FontAwesomeIcon icon="pen-to-square" />
          </button>
        </template>
        <dl class="row mb-0">
          <DescriptionListItem :title="t('name_label')">
            {{ profileFromStore.name }}
          </DescriptionListItem>

          <DescriptionListItem :title="t('currency_label')">
            {{ profileFromStore.currencyObject.name }} ({{ profileFromStore.currencyObject.symbol }})
          </DescriptionListItem>

          <DescriptionListItem :title="t('default_wallet')">
            <WalletBadge :wallet="profileFromStore.defaultWallet" />
          </DescriptionListItem>
        </dl>
      </BCard>
    </template>

    <template v-slot:wallets="{ isTabLayout }">
      <component
        :is="isTabLayout ? 'div' : 'BCard'"
        no-body
      >
        <template v-slot:header>
          <h4 class="m-0">
            {{ t('sub_header_wallets') }}
          </h4>
        </template>
        <WalletsList :class="{ 'WalletsList--lg': !isTabLayout }" />
      </component>
    </template>

    <template v-slot:categories="{ isTabLayout }">
      <component
        :is="isTabLayout ? 'div' : 'BCard'"
        no-body
      >
        <template v-slot:header>
          <h4 class="m-0">
            {{ t('sub_header_categories') }}
          </h4>
        </template>
        <CategoriesList :class="{ 'CategoriesList--lg': !isTabLayout }" />
      </component>
    </template>

    <template v-slot:sharing="{}" />
  </TabRowContainer>
</template>

<script>
import { computed } from 'vue';
import { storeToRefs } from 'pinia';
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';

import I18n from '~/utils/I18n.js';
import { profiles as profilesApi } from '~/api/all.js';
import useProfileStore from '~/stores/ProfileStore.js';
import useWalletStore from '~/stores/WalletStore.js';
import useCategoryStore from '~/stores/CategoryStore.js';

import PageHeader from '~/components/layout/PageHeader.vue';
import DropdownMenuItem from '~/components/ui/DropdownMenuItem.vue';
import BCard from '~/components/bootstrap/BCard.vue';
import Badge from '~/components/ui/Badge.vue';
import DescriptionListItem from '~/components/layout/DescriptionListItem.vue';
import TabRowContainer from '~/components/layout/TabRowContainer.vue';
import WalletsList from '~/components/wallets/WalletsList.vue';
import WalletBadge from '~/components/wallets/WalletBadge.vue';
import CategoriesList from '~/components/categories/CategoriesList.vue';

export default {
  components: {
    Badge,
    BCard,
    CategoriesList,
    DescriptionListItem,
    DropdownMenuItem,
    FontAwesomeIcon,
    PageHeader,
    TabRowContainer,
    WalletBadge,
    WalletsList,
  },

  props: {
    profile: {
      type: Object,
      required: true,
    },
  },

  setup(props) {
    const t = I18n.scopedTranslator('views.profiles.show');

    const profilesPath = profilesApi.index.path();

    const profileStore = useProfileStore();
    const walletStore = useWalletStore();
    const categoryStore = useCategoryStore();

    profileStore.setActionName('show');
    walletStore.fetchCollection();
    categoryStore.fetchCollection();

    const { profile: profileFromStore } = storeToRefs(profileStore);
    profileFromStore.value = props.profile;

    const isDisabled = computed(() => !!profileFromStore.value.disabledAt);

    const tabsConfig = computed(() => {
      const tabs = [
        {
          slot: 'summary',
          noBodyOnCard: true,
          fullHeight: true,
          title: t('sub_header_summary'),
          colClasses: 'col-6 mb-3',
        },
        {
          slot: 'wallets',
          noBodyOnCard: true,
          title: t('sub_header_wallets'),
          colClasses: 'col-6 mb-3',
        },
        {
          slot: 'categories',
          noBodyOnCard: true,
          title: t('sub_header_categories'),
          colClasses: 'col-6 mb-3',
        },
        {
          slot: 'sharing',
          noBodyOnCard: true,
          title: t('sub_header_sharing'),
          colClasses: 'col-6 mb-3',
        },
      ];

      // if (false) {
      //   tabs.splice(2, 0, { slot: 'budget', title: t('sub_header_budget'), colClasses: 'col-6 mb-3' });
      // }

      return tabs;
    });

    const handleEdit = () => profileStore.openFormModal(props.profile.id);
    const handleDisable = () => profileStore.disable(props.profile.id);
    const handleReenable = () => profileStore.reenable(props.profile.id);

    return {
      t,
      profileFromStore,
      profilesPath,
      tabsConfig,
      isDisabled,
      handleEdit,
      handleDisable,
      handleReenable,
    };
  },
};
</script>

<style lang="scss" scoped>
.WalletsList--lg, .CategoriesList--lg {
  margin: 0 -1px -1px -1px;
}
</style>
