<template>
  <div>
    <PageHeader :title="t('title', { name: category.name })" />
  </div>
</template>

<script>
import PageHeader from '~/components/layout/PageHeader.vue';
import I18n from '~/utils/I18n';

export default {
  components: {
    PageHeader,
  },

  props: {
    category: {
      type: Object,
      required: true,
    },
  },

  setup() {
    return {
      t: I18n.scopedTranslator('views.categories.show'),
    };
  },
};
</script>
