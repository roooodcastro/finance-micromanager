<template>
  <RailsForm
    id="subcategoryForm"
    :action="formAction"
    :method="formMethod"
    resource="subcategory"
  >
    <template v-slot:default="{ formHelper }">
      <FormInput
        field-name="name"
        :form-helper="formHelper"
        :value="subcategory.name"
        :label="t('name_label')"
      />
    </template>
  </RailsForm>
</template>

<script>
import { categories as categoriesApi, subcategories as subcategoriesApi } from '~/api';
import I18n from '~/utils/I18n';

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
    subcategory: {
      type: Object,
      required: true,
    },
  },

  setup(props) {
    const t = I18n.scopedTranslator('views.subcategories.form');
    const categoryPath = categoriesApi.show.path({ id: props.category.id });
    const isNewSubcategory = !props.subcategory.id;

    const formMethod = isNewSubcategory ? 'POST' : 'PATCH';
    const formAction = isNewSubcategory
      ? subcategoriesApi.create.path({ category_id: props.category.id })
      : subcategoriesApi.update.path({ category_id: props.category.id, id: props.subcategory.id });

    const formTitle = isNewSubcategory ? t('new_title') : t('edit_title', { name: props.subcategory.name });

    return {
      categoryPath,
      formMethod,
      formAction,
      formTitle,
      t,
    };
  },
};
</script>
