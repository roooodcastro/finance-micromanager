<template>
  <div>
    <PageHeader :title="I18n.t('views.landing.title')" />
  </div>
</template>

<script>
import I18n from '~/utils/I18n.js';

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
