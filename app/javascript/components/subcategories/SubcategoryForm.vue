<template>
  <RailsForm
    id="subcategoryForm"
    :action="formAction"
    :method="formMethod"
    resource="subcategory"
    @submit.prevent="handleSubmit"
  >
    <template v-slot:default="{ formHelper }">
      <FormInput
        v-model="subcategory.name"
        field-name="name"
        :form-helper="formHelper"
        :label="t('name_label')"
      />
    </template>
  </RailsForm>
</template>

<script>
import { computed } from 'vue';
import { storeToRefs } from 'pinia';

import I18n from '~/utils/I18n.js';
import { subcategories as subcategoriesApi } from '~/api';
import useSubcategoriesStore from '~/stores/SubcategoryStore.js';

import RailsForm from '~/components/rails/RailsForm.vue';
import FormInput from '~/components/rails/FormInput.vue';

export default {
  components: {
    FormInput,
    RailsForm,
  },

  props: {
    category: {
      type: Object,
      required: true,
    },
  },

  emits: ['close'],

  setup(props, { emit }) {
    const t = I18n.scopedTranslator('views.subcategories.form');

    const subcategoryStore = useSubcategoriesStore();
    const { subcategoryForFormModal: subcategory } = storeToRefs(subcategoryStore);

    const isNewSubcategory = computed(() => !subcategory.value.id);

    const formMethod = computed(() => isNewSubcategory.value ? 'POST' : 'PATCH');
    const formAction = computed(() => {
      return isNewSubcategory.value
        ? subcategoriesApi.create.path({ category_id: props.category.id })
        : subcategoriesApi.update.path({ category_id: props.category.id, id: subcategory.value.id });
    });

    const handleSubmit = () => {
      if (isNewSubcategory.value) {
        subcategoryStore
          .create(props.category.id, { name: subcategory.value.name ?? '' })
          .then(() => emit('close'));
      } else {
        subcategoryStore
          .update(props.category.id, subcategory.value.id, { name: subcategory.value.name })
          .then(() => emit('close'));
      }
    }

    return {
      t,
      formMethod,
      formAction,
      subcategory,
      handleSubmit,
    };
  },
};
</script>
