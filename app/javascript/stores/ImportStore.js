import { imports as importsApi } from '~/api/all.js';
import { IMPORT_FORM_ID } from '~/utils/Constants.js';
import { defineBaseApiStore } from '~/stores/BaseApiStore.js';

export default defineBaseApiStore('import', {
  resourceName: 'import',
  resourcesName: 'imports',
  formId: IMPORT_FORM_ID,
  api: importsApi,

  state: {
    imports: [],
    import: null,
    fetchParams: {},
  },

  actions: {
  },
});
