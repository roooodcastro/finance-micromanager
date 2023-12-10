<template>
  <FormModal
    :t="t"
    :record="subcategory"
    :form-id="SUBCATEGORY_FORM_ID"
    :modal-id="modalId"
  >
    <template v-slot:default="{ closeModal }">
      <RailsForm
        id="subcategoryForm"
        :action="formAction"
        :method="formMethod"
        resource="subcategory"
        @submit.prevent="handleSubmit(closeModal)"
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
  </FormModal>
</template>

<script>
import { computed } from 'vue';
import { storeToRefs } from 'pinia';

import I18n from '~/utils/I18n.js';
import { subcategories as subcategoriesApi } from '~/api/all.js';
import useSubcategoriesStore from '~/stores/SubcategoryStore.js';
import useModalStore from '~/stores/ModalStore.js';
import { SUBCATEGORY_FORM_ID } from '~/utils/Constants.js';

import RailsForm from '~/components/rails/RailsForm.vue';
import FormInput from '~/components/rails/FormInput.vue';
import FormModal from '~/components/forms/FormModal.vue';

export default {
  components: {
    FormModal,
    FormInput,
    RailsForm,
  },

  props: {
    category: {
      type: Object,
      required: true,
    },
  },

  setup(props) {
    const t = I18n.scopedTranslator('views.subcategories.form');

    const modalStore = useModalStore();

    const modalId = modalStore.modalId(SUBCATEGORY_FORM_ID);

    const subcategoryStore = useSubcategoriesStore();
    const { subcategoryForFormModal: subcategory } = storeToRefs(subcategoryStore);

    const isNewSubcategory = computed(() => !subcategory.value.id);

    const formMethod = computed(() => isNewSubcategory.value ? 'POST' : 'PATCH');
    const formAction = computed(() => {
      return isNewSubcategory.value
        ? subcategoriesApi.create.path({ category_id: props.category.id })
        : subcategoriesApi.update.path({ category_id: props.category.id, id: subcategory.value.id });
    });

    const handleSubmit = (closeModal) => {
      if (isNewSubcategory.value) {
        subcategoryStore
          .create(props.category.id, { name: subcategory.value.name ?? '' })
          .then(closeModal);
      } else {
        subcategoryStore
          .update(props.category.id, subcategory.value.id, { name: subcategory.value.name })
          .then(closeModal);
      }
    };

    return {
      t,
      formMethod,
      formAction,
      subcategory,
      modalId,
      handleSubmit,
      SUBCATEGORY_FORM_ID,
    };
  },
};
</script>
