<template>
  <header
    v-if="title || $slots.default"
    class="PageHeader d-flex align-items-center justify-content-between mt-lg-3 mb-lg-2"
    v-bind="$attrs"
  >
    <h1
      v-if="title || $slots.default"
      class="PageHeader__h1 d-flex align-items-center mb-0 text-break flex-fill"
    >
      <a
        v-if="!hideBackButton"
        :href="backButtonHref ?? dashboardPath"
        class="btn btn-context-action fs-3 px-3 me-2"
      >
        <FontAwesomeIcon icon="chevron-left" />
      </a>

      <span
        v-if="backButtonHref"
        class="vr me-2 me-lg-3"
      />

      <span
        class="d-flex flex-column flex-fill"
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
      v-if="$slots.actions"
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
  >
</template>

<script>
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';

import I18n from '~/utils/I18n.js';
import { dashboards as dashboardsApi } from '~/api/all.js';

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
    hideBackButton: {
      type: Boolean,
      default: false,
    },
  },
  setup(props) {
    const t = I18n.scopedTranslator('views.layout.page_header');

    const dashboardPath = dashboardsApi.show.path();

    if (props.pageTitle || props.title) {
      document.title = `${props.pageTitle || props.title} - Finance MicroManager`;
    }

    return {
      t,
      dashboardPath,
    };
  },
};
</script>

<style lang="scss" scoped>
@import '../../stylesheets/variables';

@include media-breakpoint-down(lg) {
  .PageHeader {
    background-color: var(--page-header-color);
    border-bottom: $border-width $border-style var(--bs-border-color);
    min-height: 4rem;
    padding: .5rem;
    position: sticky;
    top: 0;
    z-index: 1020;
  }
}
</style>
