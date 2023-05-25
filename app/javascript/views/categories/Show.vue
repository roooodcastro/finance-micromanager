<template>
  <div>
    <PageHeader :title="t('title')" />
  </div>
</template>

<script>
import PageHeader from '~/components/layout/PageHeader.vue';
import I18n from '~/utils/I18n';

export default {
  components: {
    PageHeader,
  },
  setup() {
    return {
      t: I18n.scopedTranslator('views.categories.new_edit'),
    };
  },
};
</script>
