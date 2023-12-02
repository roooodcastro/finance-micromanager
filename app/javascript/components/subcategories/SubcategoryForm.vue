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
import { computed } from 'vue';

import { subcategories as subcategoriesApi } from '~/api';
import I18n from '~/utils/I18n.js';

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
    const isNewSubcategory = computed(() => !props.subcategory.id);

    const formMethod = computed(() => isNewSubcategory.value ? 'POST' : 'PATCH');
    const formAction = computed(() => {
      return isNewSubcategory.value
        ? subcategoriesApi.create.path({ category_id: props.category.id })
        : subcategoriesApi.update.path({ category_id: props.category.id, id: props.subcategory.id });
    });

    return {
      formMethod,
      formAction,
      t,
    };
  },
};
</script>
