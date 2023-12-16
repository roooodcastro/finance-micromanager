import { reconciliations as reconciliationsApi } from '~/api/all.js';
import { RECONCILIATION_FORM_ID } from '~/utils/Constants.js';
import { defineBaseApiStore } from '~/stores/BaseApiStore.js';

export default defineBaseApiStore('reconciliation', {
  resourceName: 'reconciliation',
  resourcesName: 'reconciliations',
  formId: RECONCILIATION_FORM_ID,
  api: reconciliationsApi,

  state: {
    reconciliations: [],
    idForFormModal: null,
    fetchParams: {},
  },
});
