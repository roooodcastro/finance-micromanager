<template>
  <component
    :is="!!href ? 'a' : 'div'"
    :href="href"
    class="GridRow"
    :class="{ 'text-decoration-none link-body-emphasis': !!href, 'GridRow--hoverable': hoverable }"
    :style="gridRowStyle(row)"
    @click="handleRowClick"
  >
    <HorizontalSwipe
      class="GridRow__content"
      :min-translation="minTranslation"
      :max-translation="0"
    >
      <slot />
    </HorizontalSwipe>

    <div
      ref="actionsContainer"
      class="GridRow__actions"
    >
      <a
        v-for="(action, index) in actionsForRow(row)"
        :key="`row_${row.id}_action_${index}`"
        :class="`text-decoration-none text-${action.variant}`"
        :style="actionStyle(action)"
        @click="handleActionClick($event, action, row)"
      >
        <FontAwesomeIcon :icon="action.icon" />
        <span class="d-none d-lg-inline-block ms-2">
          {{ action.label }}
        </span>
      </a>
    </div>
  </component>
</template>

<script>
import { computed, ref, onMounted, onUnmounted } from 'vue';
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';

import { isMediaBreakpointUp } from '~/utils/ResponsivenessUtils.js';

import HorizontalSwipe from '~/components/layout/HorizontalSwipe.vue';

export default {
  components: {
    FontAwesomeIcon,
    HorizontalSwipe,
  },

  props: {
    row: {
      type: Object,
      required: true,
    },
    actions: {
      type: Array,
      required: true,
    },
    sideStripColor: {
      type: Function,
      default: () => {},
    },
    hoverable: {
      type: Boolean,
      default: false,
    },
    clickHandler: {
      type: Function,
      default: null,
    },
  },

  setup(props) {
    const minTranslation = ref(0);
    const actionsContainer = ref(null);

    const setMinTranslation = () => {
      if (isMediaBreakpointUp('lg')) {
        minTranslation.value = 0;
      } else {
        minTranslation.value = -actionsContainer.value.clientWidth;
      }
    };

    onMounted(() => {
      window.addEventListener('resize', setMinTranslation);

      setMinTranslation();
    });

    onUnmounted(() => window.removeEventListener('resize', setMinTranslation));

    const gridRowStyle = (row) => {
      const sideStripColor = props.sideStripColor ? props.sideStripColor(row) : null;
      return {
        '--grid-table-row-side-strip-color': sideStripColor ?? 'transparent',
        '--grid-row-padding-left': sideStripColor ? '1.5rem' : '1rem',
      };
    };

    const actionStyle = (action) => {
      return {
        '--grid-table-action-bg-color': `var(--bs-${action.variant})`,
      };
    };

    const href = computed(() => props.row?.href ?? (props.clickHandler ? '#' : null));

    const actionsForRow = row => props.actions.filter(action => action.show ? action.show(row) : true);

    const handleActionClick = (event, action, row) => {
      if (action.callback) {
        event.preventDefault();
        action.callback(row);
      } else if (action.href) {
        event.preventDefault();
        window.location.href = action.href(row);
      }
    };

    const handleRowClick = () => {
      if (props.clickHandler) {
        props.clickHandler(props.row);
      }
    };

    return {
      href,
      minTranslation,
      actionsContainer,
      gridRowStyle,
      actionStyle,
      actionsForRow,
      handleRowClick,
      handleActionClick,
    };
  }
};
</script>
