import dayjs from 'dayjs';
import { defineBaseApiStore } from '~/stores/BaseApiStore.js';

import { BUDGET_OWNER_TYPE_CATEGORY, BUDGET_OWNER_TYPE_PROFILE } from '~/utils/Constants.js';
import { budgetInstances as budgetInstancesApi } from '~/api/all.js';

export default defineBaseApiStore('budgetInstance', {
  resourceName: 'budgetInstance',
  resourcesName: 'budgetInstances',
  formId: '',
  api: budgetInstancesApi,

  state: {
    budgetInstances: [],
    budgetInstancesForHistory: [],
    budgetInstance: null,
    fetchParams: {},
  },

  getters: {
    budgetInstanceForCategory: (state) => {
      return (categoryId) => {
        return state.budgetInstances.find((budgetInstance) => {
          return budgetInstance.ownerType === BUDGET_OWNER_TYPE_CATEGORY && budgetInstance.ownerId === categoryId;
        });
      };
    },
    budgetInstanceForProfile: (state) => {
      return state.budgetInstances.find(budgetInstance => budgetInstance.ownerType === BUDGET_OWNER_TYPE_PROFILE);
    }
  },

  actions: {
    fetchSingle(id) {
      this.loading = true;
      budgetInstancesApi
        .show({ id, query: this.fetchParams })
        .then(response => this.budgetInstance = response.budgetInstance)
        .finally(() => this.loading = false);
    },

    fetchForHistory(ownerId, referenceDate = null) {
      const endDate = referenceDate ?? dayjs().tz('utc').utc();
      const startDate = endDate.subtract(13, 'months');

      this.fetchCollection({
        targetVariable: 'budgetInstancesForHistory',
        fetchParams: { startDate, endDate, ownerId }
      });
    },
  },
});
