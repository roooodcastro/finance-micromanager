<template>
  <FormModal
    :t="t"
    :record="category"
    :form-id="CATEGORY_FORM_ID"
    :modal-id="modalId"
  >
    <template v-slot:default="{ closeModal }">
      <RailsForm
        :id="CATEGORY_FORM_ID"
        :action="formAction"
        method="PATCH"
        resource="category"
        @submit.prevent="handleSubmit(closeModal)"
      >
        <template v-slot:default="{ formHelper }">
          <FormInput
            v-model="category.name"
            field-name="name"
            :form-helper="formHelper"
            :label="t('name_label')"
            class="focus"
          />

          <label
            :for="formHelper.fieldId('color')"
            class="form-label"
          >
            {{ t('color_label') }}
          </label>
          <ColorPickerInput
            :id="formHelper.fieldId('color')"
            v-model="category.color"
            :name="formHelper.fieldName('color')"
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
import { categories as categoriesApi } from '~/api/all.js';
import useCategoryStore from '~/stores/CategoryStore.js';
import useModalStore from '~/stores/ModalStore.js';
import { CATEGORY_FORM_ID } from '~/utils/Constants.js';

import RailsForm from '~/components/rails/RailsForm.vue';
import FormInput from '~/components/rails/FormInput.vue';
import FormModal from '~/components/forms/FormModal.vue';
import ColorPickerInput from '~/components/forms/ColorPickerInput.vue';

export default {
  components: {
    ColorPickerInput,
    FormInput,
    FormModal,
    RailsForm,
  },

  setup() {
    const t = I18n.scopedTranslator('views.categories.form');

    const modalStore = useModalStore();
    const modalId = modalStore.modalId(CATEGORY_FORM_ID);

    const categoryStore = useCategoryStore();
    const { categoryForFormModal: category } = storeToRefs(categoryStore);

    const isNewRecord = computed(() => !category.value.id);

    const formAction = isNewRecord.value
      ? categoriesApi.create.path()
      : categoriesApi.update.path({ id: category.value.id });

    const handleSubmit = (closeModal) => {
      if (isNewRecord.value) {
        categoryStore.create(category.value).then(closeModal);
      } else {
        categoryStore.update(category.value.id, category.value).then(closeModal);
      }
    };

    return {
      t,
      modalId,
      category,
      formAction,
      handleSubmit,
      CATEGORY_FORM_ID,
    };
  },
};
</script>
