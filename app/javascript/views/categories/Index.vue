<template>
  <PageHeader :title="t('title')">
    <template v-slot:actions>
      <DropdownMenuItem
        :label="t('new')"
        icon="plus"
        @click="handleNew"
      />

      <hr class="my-2">

      <DropdownMenuCheckItem
        :label="t('show_system')"
        :checked="showSystem"
        @click="handleShowSystem"
      />

      <DropdownMenuCheckItem
        :label="t('show_disabled')"
        :checked="showDisabled"
        @click="handleShowDisabled"
      />
    </template>
  </PageHeader>

  <CategoriesList />

  <CategoryForm />
</template>

<script>
import { storeToRefs } from 'pinia';

import I18n from '~/utils/I18n.js';
import useCategoryStore from '~/stores/CategoryStore.js';
import useFloatingActionButtonStore from '~/stores/FloatingActionButtonStore.js';
import { CATEGORY_OPTIONS_COOKIE_NAME, ICON_CATEGORIES } from '~/utils/Constants.js';
import { getValueFromJsonCookie, setValueToJsonCookie } from '~/utils/CookieUtils.js';
import { onProfileChanged } from '~/utils/OnProfileChangeWatcher.js';

import PageHeader from '~/components/layout/PageHeader.vue';
import CategoriesList from '~/components/categories/CategoriesList.vue';
import DropdownMenuItem from '~/components/ui/DropdownMenuItem.vue';
import DropdownMenuCheckItem from '~/components/ui/DropdownMenuCheckItem.vue';
import CategoryForm from '~/components/categories/CategoryForm.vue';

export default {
  components: {
    CategoriesList,
    CategoryForm,
    DropdownMenuCheckItem,
    DropdownMenuItem,
    PageHeader,
  },

  setup() {
    const categoryStore = useCategoryStore();
    const { categories: categoriesFromStore, showDisabled, showSystem } = storeToRefs(categoryStore);

    const floatingActionButtonStore = useFloatingActionButtonStore();
    floatingActionButtonStore.registerSpeedDialEntry({
      label: I18n.t('views.categories.floating_button_label'),
      icon: ICON_CATEGORIES,
      callback: () => categoryStore.openFormModal(null),
      shortcut: { keys: 'alt+n', keyLabels: ['alt', 'n'] },
    });

    const initialShowDisabled = !!getValueFromJsonCookie(CATEGORY_OPTIONS_COOKIE_NAME, 'sd');
    const initialShowSystem = !!getValueFromJsonCookie(CATEGORY_OPTIONS_COOKIE_NAME, 'ss');
    categoryStore.setFetchParams({ showDisabled: initialShowDisabled, showSystem: initialShowSystem });
    categoryStore.fetchCollection();

    onProfileChanged(() => categoryStore.fetchCollection());

    const handleNew = () => categoryStore.openFormModal(null);
    const handleShowDisabled = () => {
      categoryStore.setFetchParams({ showDisabled: !showDisabled.value });
      setValueToJsonCookie(CATEGORY_OPTIONS_COOKIE_NAME, 'sd', showDisabled.value);
      categoryStore.fetchCollection();
    };
    const handleShowSystem = () => {
      categoryStore.setFetchParams({ showSystem: !showSystem.value });
      setValueToJsonCookie(CATEGORY_OPTIONS_COOKIE_NAME, 'ss', showSystem.value);
      categoryStore.fetchCollection();
    };

    return {
      t: I18n.scopedTranslator('views.categories.index'),
      categoriesFromStore,
      showDisabled,
      showSystem,
      handleNew,
      handleShowDisabled,
      handleShowSystem,
    };
  },
};
</script>
