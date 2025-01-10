<template>
  <div
    v-if="searchable"
    class="GridTable__search d-flex mb-3"
  >
    <SearchField
      :debounce-timeout="searchDebounceTimeout"
      :placeholder="t('search_placeholder')"
      @input="handleSearchInput"
    />
  </div>

  <div
    class="GridTable border rounded"
    :style="gridTableStyle"
  >
    <div class="GridRow GridRow__header">
      <div
        v-if="leftColumns.length"
        class="GridRow__left"
      >
        <div
          v-for="(column, columnIndex) in leftColumns"
          :key="`header_left_${columnIndex}`"
          :class="{ 'text-end': column.align === 'right' }"
        >
          <h5
            v-for="(label, labelIndex) in headerLabels(column)"
            :key="`header_left_label_${labelIndex}`"
            class="d-block m-0"
          >
            {{ label }}
          </h5>
        </div>
      </div>

      <div
        v-if="rightColumns.length"
        class="GridRow__right"
      >
        <div
          v-for="(column, columnIndex) in rightColumns"
          :key="`header_right_${columnIndex}`"
          :class="{ 'text-end': column.align === 'right' }"
        >
          <h5
            v-for="(label, labelIndex) in headerLabels(column)"
            :key="`header_right_label_${labelIndex}`"
            class="d-block m-0"
          >
            {{ label }}
          </h5>
        </div>
      </div>
    </div>

    <template
      v-for="row in rows"
      :key="row.id"
    >
      <GridTableRow
        :row="row"
        :actions="actions"
        :side-strip-color="sideStripColor"
      >
        <slot :row="row" />
      </GridTableRow>
    </template>
  </div>
</template>

<script>
import { computed } from 'vue';

import I18n from '~/utils/I18n.js';

import GridTableRow from '~/components/ui/GridTableRow.vue';
import SearchField from '~/components/ui/SearchField.vue';

export default {
  components: {
    GridTableRow,
    SearchField,
  },

  props: {
    /*
     * Columns specification. The number of entries here determines the number of columns the table will have.
     * If actions is specificied, an extra column will be added to the table to hold the actions when in desktop view.
     * Each entry has the following specification:
     *
     * {
     *   label: Label for the column, displayed in the header for the user. Required.
     *   side: Can be either 'left'or 'right'. Indicates the side of the table in which the column will be rendered
     *         when in mobile view. Required.
     *   align: Text align option. Can be 'left', 'center', or 'right'. Optional.
     *   gridSize: the CSS Grid value for the column when specifying the grid-template-columns property. Optional.
     * }
     */
    columns: {
      type: Array,
      required: true,
    },
    /*
     * Data for the table. Has no specific format, as each entry will be passed as a slot variable when rendering.
     */
    rows: {
      type: Array,
      required: true,
    },

    /*
     * Defines the actions for each row. These will be displayed either in a drawer context menu in mobile view, or in
     * the far right side of the table. Each entry has the following specification:
     *
     * {
     *   label: Label text for the action. Displayed only in desktop view when present. Optional.
     *   icon: Name of the FontAwesome icon to be displayed. Required.
     *   variant: Bootstrap variant name to colour the action. Required.
     *   show: Function that accepts the row as parameter, used to determine if this action should be displayed or not.
     *         Optional, action will always be displayed if not present.
     *   href: Path or URL to redirect the user when clicked. Optional.
     *   callback: Function that accepts the row as parameter, will be called when the action is clicked. If both href
     *             and callback options are specified, callback will take precedence and href won't work. Optional.
     * }
     */
    actions: {
      type: Array,
      default: () => [],
    },

    /*
     * Optional function that returns the colour for the side strip of a specific data row. The function will be called
     * passing the row object as parameter. The return value should be a CSS colour value to be used as the side strip,
     * or null if no side strip should be shown.
     */
    sideStripColor: {
      type: Function,
      default: () => {},
    },

    /*
     * Defines if a search field should be included at the top of the table. If included, it will trigger a search
     * event when the search field has any input. This event is debounced using the searchDebounceTimeout prop.
     * Defaults to false. Optional.
     */
    searchable: {
      type: Boolean,
      default: false,
    },

    /*
     * Used if searchable prop if true. This defines a debounce interval, in milliseconds, to apply to the search input
     * field. This means that the search event will only be emitted after the user hasn't typed in the configured time.
     * Defaults to 300. Optional.
     */
    searchDebounceTimeout: {
      type: Number,
      default: 300,
    },
  },

  emits: ['search'],

  setup(props, { emit }) {
    const t = I18n.scopedTranslator('views.layout.grid_table');

    const actionColumn = { name: 'action', label: '', side: 'right', gridSize: 'max-content' };
    const allColumns = computed(() => props.columns.concat(props.actions.length ? [actionColumn] : []));
    const leftColumns = computed(() => allColumns.value.filter(column => column.side === 'left'));
    const rightColumns = computed(() => allColumns.value.filter(column => column.side === 'right' && column.name !== 'action'));

    const midGridColumn = computed(() => {
      if (!rightColumns.value.length) {
        return -1;
      }
      if (!leftColumns.value.length) {
        return 1;
      }

      return leftColumns.value.length + 1;
    });
    const gridTableStyle = computed(() => {
      return {
        'grid-template-columns': allColumns.value.map(column => (column.gridSize ?? 'auto')).join(' '),
        '--grid-table-left-grid-column': [1, midGridColumn.value].join(' / '),
        '--grid-table-right-grid-column': [midGridColumn.value, -1].join(' / '),
        '--grid-row-content-grid-end': props.actions.length ? -2 : -1,
      };
    });

    const headerLabels = (column => column.label.split('\n'));

    const handleSearchInput = searchString => emit('search', searchString);

    return {
      t,
      gridTableStyle,
      leftColumns,
      rightColumns,
      headerLabels,
      handleSearchInput,
    };
  }
}
</script>

// eslint-disable-next-line vue-scoped-css/enforce-style-type
<style lang="scss">
@import '../../stylesheets/variables';

.GridTable {
  background-color: var(--bs-secondary-bg);
  display: grid;
  grid-template-columns: auto auto auto auto;
  align-items: center;
  --grid-row-padding-left: 1rem;
}

.GridRow {
  align-items: center;
  background-color: var(--foreground-color);
  border-top: 1px solid var(--bs-border-color);
  display: grid;
  grid-template-columns: subgrid;
  grid-column: 1 / -1;
  position: relative;
  z-index: 0;

  .GridRow__content .GridRow__left, .GridRow__content .GridRow__right {
    background-color: var(--foreground-color);
  }

  &:first-child {
    border-top: none;
  }
}

// Hover effect for rows that are links
a.GridRow:hover, a.GridRow.active, a.GridRow.focus {
  background-color: transparent !important;

  .GridRow__content > * {
    background-color: transparent !important;
  }
}

// Grid positioning for left and right sides
.GridRow__left, .GridRow__right {
  align-items: center;
  display: grid;
  grid-template-columns: subgrid;

  > div {
    padding: 0 map-get($spacers, 2);

    &:first-child {
      padding-left: 0;
    }
    &:last-child {
      padding-right: 0;
    }
  }
}

.GridRow__left {
  grid-column: var(--grid-table-left-grid-column);
  padding: map-get($spacers, 2) 0 map-get($spacers, 2) var(--grid-row-padding-left);
}

.GridRow__right {
  grid-column: var(--grid-table-right-grid-column);
  padding: map-get($spacers, 2) map-get($spacers, 3) map-get($spacers, 2) 0;
}

// Header row
.GridRow__header {
  font-weight: bold;
  background-color: transparent !important;
  color: var(--bs-secondary-color);

  span {
    white-space: pre;
  }

  > .GridRow__left > div > h5:not(:first-child), > .GridRow__right > div > h5:not(:first-child) {
    font-size: $h6-font-size;
    margin-top: map-get($spacers, 1) !important;
  }

  .GridRow__right > div:last-child {
    margin-right: 1rem;
  }
}

// Data rows
.GridRow__content {
  display: grid;
  grid-template-columns: subgrid;
  grid-column: 1 / var(--grid-row-content-grid-end);
  position: relative;
}

// Side Strip
.GridRow__content::before {
  content: '';
  position: absolute;
  left: 0;
  top: 0;
  height: 100%;
  width: $side-strip-width;
  background-color: var(--grid-table-row-side-strip-color);
}

// Rounded corners for first data row
.GridRow:nth-child(2) {
  border-radius: $border-radius $border-radius 0 0;

  .GridRow__content {
    border-radius: $border-radius $border-radius 0 0;

    &::before {
      border-top-left-radius: $border-radius;
    }

    .GridRow__left {
      border-top-left-radius: $border-radius;
    }

    .GridRow__right {
      border-top-right-radius: $border-radius;
    }
  }
}

// Rouded corners for last data row
.GridRow:last-child {
  border-radius: 0 0 $border-radius $border-radius;

  .GridRow__content {
    border-radius: 0 0 $border-radius $border-radius;

    &::before {
      border-bottom-left-radius: $border-radius;
    }

    .GridRow__left {
      border-bottom-left-radius: $border-radius;
    }

    .GridRow__right {
      border-bottom-right-radius: $border-radius;
    }
  }
}

// Actions section
.GridRow__actions {
  grid-column: -1 / -1;
  display: flex;
  justify-content: end;
  align-self: stretch;
  align-items: center;

  > a {
    cursor: pointer;
    display: flex;
    height: 100%;
    align-items: center;
    padding: 0 map-get($spacers, 3);
    position: relative;
    z-index: 0;

    &:hover::before, &:active::before, &:focus::before, &:hover::after, &:active::after, &:focus::after {
      content: '';
      background-color: var(--bs-secondary-bg);
      border-radius: $border-radius;
      position: absolute;
      left: map-get($spacers, 1);
      right: map-get($spacers, 1);
      top: map-get($spacers, 1);
      bottom: map-get($spacers, 1);
      z-index: -1;
    }

    &:hover::after, &:active::after, &:focus::after {
      background-color: var(--grid-table-action-bg-color);
      opacity: 0.25;
    }

    &:first-child {
      margin-left: 0;
    }

    &:last-child {
      margin-right: 0;
    }
  }
}

// Mobile view
@include media-breakpoint-down(md) {
  .GridTable__search {
    margin: 0 map-get($spacers, 3);

    > div {
      width: 100% !important;
    }
  }
}

@include media-breakpoint-down(lg) {
  .GridRow__left > *, .GridRow__right > * {
    grid-column: 1 / -1;
  }

  .GridRow__header > .GridRow__left > div:not(:first-child) > h5,
  .GridRow__header > .GridRow__left > div:first-child > h5:not(:first-child),
  .GridRow__header > .GridRow__right > div:not(:first-child) > h5,
  .GridRow__header > .GridRow__right > div:first-child > h5:not(:first-child) {
    font-size: $h6-font-size;
    margin-top: map-get($spacers, 1) !important;
  }

  .GridRow__header > .GridRow__right > div:last-child {
    margin-right: 0;
  }

  .GridRow:not(.GridRow__header) .GridRow__left > div:not(:first-child),
  .GridRow:not(.GridRow__header) .GridRow__right > div:not(:first-child) {
    color: var(--bs-secondary-color);
    font-size: $h6-font-size;
  }

  .GridRow__content {
    grid-column-end: -1;
    position: relative;
  }

  .GridRow__left > div {
    text-align: left;
    padding-left: 0;
  }

  .GridRow__right > div {
    text-align: right;
    padding-right: 0;
  }

  .GridRow__actions {
    position: absolute;
    bottom: 0;
    top: 0;
    right: 0;
    z-index: -1;

    > a {
      aspect-ratio: 1;
      background-color: var(--grid-table-action-bg-color);
      color: var(--bs-light) !important;
      padding: 0 map-get($spacers, 4);
      justify-content: center;
    }
  }

  .GridRow:nth-child(2) > .GridRow__actions > a:last-child {
    border-top-right-radius: $border-radius;
  }

  .GridRow:last-child > .GridRow__actions > a:last-child {
    border-bottom-right-radius: $border-radius;
  }
}
</style>
