<template>
  <div class="vr mx-3 d-none d-lg-flex" />

  <template v-if="isDisabled">
    <DrawerContextMenuLink
      variant="success"
      icon="repeat"
      href="#"
      :label="compact ? '' : t('reenable_label')"
      :drawer="drawerMenu"
      :class="{ 'WalletActions__reenable-button': !drawerMenu }"
      @click="handleReenable"
    />
  </template>
  <template v-else>
    <EditButton
      small
      href="#"
      :compact="compact"
      :class="{ 'd-flex align-items-center justify-content-center bg-secondary text-white': drawerMenu }"
      @click="handleEdit"
    />

    <div class="vr mx-3 d-none d-lg-flex" />

    <DeleteButton
      small
      disable-label
      href="#"
      :compact="compact"
      :class="{ 'd-flex align-items-center justify-content-center bg-danger text-white': drawerMenu }"
      ask-confirmation
      @delete="handleDelete"
    />
  </template>
</template>

<script>
import { computed } from 'vue';

import I18n from '~/utils/I18n.js';
import useWalletStore from '~/stores/WalletStore.js';

import EditButton from '~/components/rails/EditButton.vue';
import DeleteButton from '~/components/rails/DeleteButton.vue';
import DrawerContextMenuLink from '~/components/ui/DrawerContextMenuLink.vue';

export default {
  components: {
    DrawerContextMenuLink,
    DeleteButton,
    EditButton
  },

  props: {
    record: {
      type: Object,
      required: true,
    },
    drawerMenu: {
      type: Boolean,
      default: false,
    },
    compact: {
      type: Boolean,
      default: false,
    },
  },

  setup(props) {
    const t = I18n.scopedTranslator('views.wallets.list');
    const walletStore = useWalletStore();

    const isDisabled = computed(() => !!props.record.disabledAt);

    const handleEdit = () => walletStore.openFormModal(props.record.id);
    const handleDelete = () => walletStore.disable(props.record.id);
    const handleReenable = () => walletStore.reenable(props.record.id);

    return {
      t,
      handleEdit,
      handleDelete,
      handleReenable,
      isDisabled,
    };
  },
};
</script>

<style lang="scss" scoped>
@import '../../stylesheets/variables';

.WalletActions__reenable-button {
  background-color: $light-bg-subtle;
  margin: -0.5rem -0.5rem -0.5rem -1rem;
  padding: 0.5rem 0.5rem 0.5rem 1rem;
}
</style>
