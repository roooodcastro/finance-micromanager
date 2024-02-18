<template>
  <div class="vr mx-3 d-none d-lg-flex" />

  <EditButton
    small
    compact
    href="#"
    :class="{ 'd-flex align-items-center justify-content-center bg-secondary text-white': drawerMenu }"
    @click="handleEdit"
  />

  <div class="vr mx-3 d-none d-lg-flex" />

  <DeleteButton
    small
    compact
    href="#"
    :class="{
      'd-flex align-items-center justify-content-center bg-danger text-white': drawerMenu,
      'me-0 me-lg-3': !drawerMenu,
    }"
    @delete="handleDelete"
  />
</template>

<script>
import I18n from '~/utils/I18n.js';
import useImportNameStore from '~/stores/ImportNameStore.js';

import EditButton from '~/components/rails/EditButton.vue';
import DeleteButton from '~/components/rails/DeleteButton.vue';

export default {
  components: {
    DeleteButton,
    EditButton
  },

  props: {
    importName: {
      type: Object,
      required: true,
    },
    drawerMenu: {
      type: Boolean,
      default: false,
    },
  },

  setup(props) {
    const t = I18n.scopedTranslator('views.import_names.list');
    const importNameStore = useImportNameStore();

    const handleEdit = () => importNameStore.openFormModal(props.importName.id);
    const handleDelete = () => importNameStore.destroy(props.importName.id);

    return {
      t,
      handleEdit,
      handleDelete,
    };
  },
};
</script>
