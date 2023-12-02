<template>
  <header
    v-if="title || $slots.default"
    class="PageHeader d-flex align-items-center justify-content-between mt-lg-3"
    v-bind="$attrs"
  >
    <h1
      v-if="title || $slots.default"
      class="PageHeader__h1 d-flex align-items-center mb-0 mb-lg-2"
    >
      <a
        v-if="backButtonHref"
        :href="backButtonHref"
        class="btn btn-context-action fs-3 px-3 me-2"
      >
        <FontAwesomeIcon icon="chevron-left" />
      </a>

      <span
        v-if="backButtonHref"
        class="vr me-2 me-lg-3"
      />

      <span
        class="d-flex flex-column"
        :class="{ 'ps-2': !backButtonHref }"
      >
        <span v-if="title">
          {{ title }}
        </span>
        <slot v-else />

        <template v-if="subTitle">
          <span class="fs-4 text-muted d-block">
            {{ subTitle }}
          </span>
        </template>
      </span>
    </h1>

    <DropdownMenu
      toggle-icon="gear"
      toggle-class="fs-3"
      :toggle-label="t('action_toggle_label')"
    >
      <slot name="actions" />
    </DropdownMenu>
  </header>

  <hr
    v-if="title || $slots.default"
    class="d-none d-lg-block"
  />
</template>

<script>
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';

import I18n from '~/utils/I18n.js';

import DropdownMenu from '~/components/ui/DropdownMenu.vue';

export default {
  components: {
    DropdownMenu,
    FontAwesomeIcon,
  },

  props: {
    title: {
      type: String,
      default: null,
    },
    subTitle: {
      type: String,
      default: '',
    },
    pageTitle: {
      type: String,
      default: '',
    },
    backButtonHref: {
      type: String,
      default: null,
    },
  },
  setup(props) {
    const t = I18n.scopedTranslator('views.layout.page_header');

    if (props.pageTitle || props.title) {
      document.title = `${props.pageTitle || props.title} - Finance MicroManager`;
    }

    return { t };
  },
};
</script>

<style lang="scss" scoped>
@import '../../stylesheets/variables';

@include media-breakpoint-down(md) {
  .PageHeader {
    background-color: $light-bg-subtle;
    margin: -1rem -1rem 1.5rem -1rem;
    padding: .5rem;
    box-shadow: var(--bs-box-shadow);
    min-height: 4rem;
  }
}
</style>
