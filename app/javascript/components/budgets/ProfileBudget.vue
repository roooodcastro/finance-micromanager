<template>
  <BCard :title="t('profile_subheader')">
    <div
      v-if="!!profileBudget"
      class="d-flex justify-content-between gap-3"
    >
      <span class="fs-1">
        <template v-if="profileBudget.limitType === BUDGET_LIMIT_TYPE_ABSOLUTE">
          {{ t('monthly_budget_absolute_desc', { amount: profileBudget.formattedLimit }) }}
        </template>
        <template v-else>
          {{ t('monthly_budget_percentage_desc', { percentage: profileBudget.formattedLimit }) }}
        </template>
      </span>
      <div class="d-flex gap-2">
        <a
          :href="showPath"
          class="btn btn-outline-primary btn-sm d-flex gap-2 align-items-center"
        >
          <FontAwesomeIcon
            icon="circle-info"
            size="lg"
          />
          <span class="d-none d-lg-inline">
            {{ t('show') }}
          </span>
        </a>
        <button
          class="btn btn-outline-secondary btn-sm"
          @click="handleEdit"
        >
          <FontAwesomeIcon
            icon="pen-to-square"
            size="lg"
          />
          <span class="d-none d-lg-inline ms-2">
            {{ t('edit') }}
          </span>
        </button>
        <button
          class="btn btn-outline-danger btn-sm"
          @click="handleDelete"
        >
          <FontAwesomeIcon
            :icon="['far', 'trash-can']"
            size="lg"
          />
        </button>
      </div>
    </div>

    <div
      v-else
      class="d-flex justify-content-between gap-3"
    >
      <span class="fs-1">
        {{ t('no_budget_set') }}
      </span>
      <button
        class="btn btn-primary"
        @click="handleNew"
      >
        <FontAwesomeIcon
          icon="plus"
          class="me-2"
        />
        {{ t('new') }}
      </button>
    </div>
  </BCard>
</template>

<script>
import { storeToRefs } from 'pinia';
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';

import I18n from '~/utils/I18n.js';
import useBudgetStore from '~/stores/BudgetStore.js';
import useProfileStore from '~/stores/ProfileStore.js';
import { budgets as budgetsApi } from '~/api/all.js';
import { BUDGET_OWNER_TYPE_PROFILE, BUDGET_LIMIT_TYPE_ABSOLUTE } from '~/utils/Constants.js';

import BCard from '~/components/bootstrap/BCard.vue';

export default {
  components: {
    BCard,
    FontAwesomeIcon,
  },

  setup() {
    const t = I18n.scopedTranslator('views.budgets.index');

    const budgetStore = useBudgetStore();
    const profileStore = useProfileStore();
    const { currentProfile } = storeToRefs(profileStore);
    const { profileBudget } = storeToRefs(budgetStore);

    const showPath = budgetsApi.show.path({ id: profileBudget.value?.id });

    const handleNew = () => {
      budgetStore.openFormModal(null, { ownerType: BUDGET_OWNER_TYPE_PROFILE, ownerId: currentProfile.value.id });
    };

    const handleEdit = () => budgetStore.openFormModal(profileBudget.value.id);
    const handleDelete = () => budgetStore.disable(profileBudget.value.id);

    return {
      t,
      profileBudget,
      showPath,
      handleNew,
      handleEdit,
      handleDelete,
      BUDGET_LIMIT_TYPE_ABSOLUTE,
    };
  },
};
</script>
