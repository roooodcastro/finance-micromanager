<template>
  <RailsForm
    :action="formAction"
    :method="formMethod"
    resource="category"
  >
    <template v-slot:default="{ formHelper }">
      <div class="card">
        <div class="card-body">
          <h4 class="card-title">
            {{ formTitle }}
          </h4>

          <hr />

          <FormInput
            field-name="name"
            :form-helper="formHelper"
            :value="category.name"
            label="Name"
          />

          <label
            :for="formHelper.fieldId('color')"
            class="form-label"
          >
            Category Color
          </label>
          <input
            :id="formHelper.fieldId('color')"
            type="color"
            class="form-control form-control-color"
            :name="formHelper.fieldName('color')"
            :value="category.color"
            title="Choose a color"
          >
        </div>

        <div class="card-footer">
          <div class="d-grid gap-2 d-md-flex">
            <button
              type="submit"
              class="btn btn-primary flex-md-fill"
            >
              Submit
            </button>

            <a
              :href="listCategoriesPath"
              class="btn btn-outline-secondary flex-md-fill"
            >
              Back
            </a>
          </div>
        </div>
      </div>
    </template>
  </RailsForm>
</template>

<script>
import { categories } from '~/api';

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

  setup(props) {
    const listCategoriesPath = categories.list.path();
    const isNewCategory = !props.category.id;

    const formMethod = isNewCategory ? 'POST' : 'PATCH';
    const formAction = isNewCategory
      ? categories.create.path()
      : categories.update.path({ id: props.category.id });

    const formTitle = isNewCategory ? 'New Category' : `Edit Category "${props.category.name}"`;

    return {
      listCategoriesPath,
      formMethod,
      formAction,
      formTitle,
    };
  },
};
</script>
