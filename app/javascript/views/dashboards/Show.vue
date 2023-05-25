<template>
  <div>
    <PageHeader :title="I18n.t('views.dashboard.title')" />
  </div>
</template>

<script>
import I18n from '~/utils/I18n';

import PageHeader from '~/components/layout/PageHeader.vue';

export default {
  components: {
    PageHeader,
  },
  setup() {
    return { I18n };
  },
};
</script>
