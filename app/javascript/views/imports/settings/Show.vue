<template>
  <div>
    <PageHeader :title="t('title')" />

    <BCard no-body>
      <template v-slot:header>
        <div class="d-flex justify-content-between align-items-center">
          <h5 class="m-0">
            {{ t('sub_header_import_name', { count: importNames.length }) }}
          </h5>

          <DropdownMenu
            toggle-icon="gear"
            :toggle-label="t('import_names_menu_aria_label')"
          >
            <DropdownMenuItem
              :label="t('new_import_name')"
              icon="plus"
              @click="handleNewImportName"
            />
          </DropdownMenu>
        </div>
      </template>

      <InfoAlert
        :message="t('import_name_info_text')"
        class="m-3"
      />

      <ImportNamesList />
    </BCard>

    <ImportNameForm />
  </div>
</template>

<script>
import { watch } from 'vue';
import { storeToRefs } from 'pinia';

import I18n from '~/utils/I18n.js';
import useProfileStore from '~/stores/ProfileStore.js';
import useImportNameStore from '~/stores/ImportNameStore.js';
import useFloatingActionButtonStore from '~/stores/FloatingActionButtonStore.js';

import PageHeader from '~/components/layout/PageHeader.vue';
import DropdownMenuItem from '~/components/ui/DropdownMenuItem.vue';
import ImportNameForm from '~/components/import_names/ImportNameForm.vue';
import ImportNamesList from '~/components/import_names/ImportNamesList.vue';
import BCard from '~/components/bootstrap/BCard.vue';
import DropdownMenu from '~/components/ui/DropdownMenu.vue';
import InfoAlert from '~/components/bootstrap/InfoAlert.vue';


export default {
  components: {
    BCard,
    DropdownMenu,
    DropdownMenuItem,
    ImportNameForm,
    ImportNamesList,
    InfoAlert,
    PageHeader,
  },

  setup() {
    const t = I18n.scopedTranslator('views.imports.settings.show');

    const importNameStore = useImportNameStore();
    importNameStore.setActionName('index');

    const floatingActionButtonStore = useFloatingActionButtonStore();
    floatingActionButtonStore.registerSpeedDialEntry({
      label: I18n.t('views.import_names.floating_button_label'),
      icon: 'right-left',
      callback: () => importNameStore.openFormModal(null),
    });

    const profileStore = useProfileStore();
    const { currentProfile } = storeToRefs(profileStore);
    watch(currentProfile, () => importNameStore.fetchCollection());

    const { importNames } = storeToRefs(importNameStore);
    importNameStore.fetchCollection();

    const handleNewImportName = () => importNameStore.openFormModal(null);

    return {
      t,
      importNames,
      handleNewImportName,
    };
  },
};
</script>
