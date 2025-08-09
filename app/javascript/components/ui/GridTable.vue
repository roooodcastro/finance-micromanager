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
    ref="gridTable"
    class="GridTable"
    :class="{ 'border': bordered, rounded, 'mobile': forceMobile }"
    :style="gridTableStyle"
  >
    <div
      v-if="!noHeader"
      class="GridRow GridRow__header"
    >
      <div
        v-if="leftColumns.length"
        class="GridRow__left"
      >
        <div
          v-for="(column, columnIndex) in leftColumns"
          :key="`header_left_${columnIndex}`"
          :class="{
            'text-end': column.align === 'right',
            'GridRow--sortable': !!column.sortColumn,
            'text-body-emphasis': column.sortColumn === sorting?.sortColumn,
          }"
        >
          <h5
            v-for="(label, labelIndex) in headerLabels(column)"
            :key="`header_left_label_${labelIndex}`"
            class="d-block m-0"
            @click="handleSorting(column)"
          >
            <FontAwesomeIcon
              v-if="!!column.sortColumn"
              :icon="sortIconFor(column)"
            />
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
          :class="{
            'text-end': column.align === 'right',
            'GridRow--sortable': !!column.sortColumn,
            'text-body-emphasis': column.sortColumn === sorting?.sortColumn,
          }"
        >
          <h5
            v-for="(label, labelIndex) in headerLabels(column)"
            :key="`header_right_label_${labelIndex}`"
            class="d-block m-0"
            @click="handleSorting(column)"
          >
            <FontAwesomeIcon
              v-if="!!column.sortColumn"
              :icon="sortIconFor(column)"
            />
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
        :hoverable="hoverable"
        :click-handler="rowClickHandler"
      >
        <slot
          :row="row"
          :forced-mobile="forceMobile"
        />
      </GridTableRow>
    </template>
  </div>
</template>

<script>
import { computed, onMounted, onUnmounted, ref } from 'vue';
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';

import I18n from '~/utils/I18n.js';

import GridTableRow from '~/components/ui/GridTableRow.vue';
import SearchField from '~/components/ui/SearchField.vue';

export default {
  components: {
    FontAwesomeIcon,
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
     *   sortColumn: The DB column that should be used for sorting for this column. The presence of this indicates
     *               that the column is sortable.
     * }
     */
    actions: {
      type: Array,
      default: () => [],
    },

    /*
     * Defines the CSS grid-template-columns size for the actions grid column.
     * Defaults to "max-content"
     */
    actionsGridSize: {
      type: String,
      default: null,
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
     * Defines the active sorting column and direction for the grid table. Only columns that are sortable (have the
     * sortColumn attribute) are valid. The object structure is:
     * { sortColumn: "dataColumn", sortDdirection: "asc|desc" }
     * Optional, should only be used when at least 1 column is sortable.
     */
    sorting: {
      type: Object,
      default: () => {},
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

    /*
     * Used when the grid rows do not have clickable links. This option forces the row to have hover highlighting for
     * easier navigation.
     */
    hoverable: {
      type: Boolean,
      default: false,
    },

    /*
     * Adds borders to the table
     */
    bordered: {
      type: Boolean,
      default: false,
    },

    /*
     * Makes the edges of the table slightly rounded
     */
    rounded: {
      type: Boolean,
      default: false,
    },

    /*
     * Displays the mobile view when the total width of the container is smaller than the width of the specified
     * Bootstrap breakpoint. For example, if the screen size is 1920px, but the layout has 3 columns, and this grid
     * table is rendered in a column that has a width of 800px, the grid would render in mobile view if this prop is
     * passed as "lg", which has a width of 960px. This also accepts the string "always", indicating that the grid table
     * will always display with a mobile layout.
     */
    forceMobileWhenSmallerThan: {
      type: String,
      default: null,
    },

    /*
     * Does not render the table header
     */
    noHeader: {
      type: Boolean,
      default: false,
    },

    /*
     * Sets an explicit behaviour when a row is clicked. If set, the row will behave as if the entry has a href
     * attribute, and will make the whole row hoverable and clickable.
     */
    rowClickHandler: {
      type: Function,
      default: null,
    },
  },

  emits: ['search', 'sort'],

  setup(props, { emit }) {
    const t = I18n.scopedTranslator('views.layout.grid_table');
    const gridTable = ref(null);
    const isMounted = ref(false);
    const gridTableWidth = ref(0);

    const forceMobile = computed(() => {
      if (!isMounted.value || !props.forceMobileWhenSmallerThan) {
        return false;
      }

      if (props.forceMobileWhenSmallerThan === 'always') {
        return true;
      }

      const breakpointVariable = `--bs-breakpoint-${props.forceMobileWhenSmallerThan}`;
      const breakpointWidth = parseInt(window.getComputedStyle(gridTable.value).getPropertyValue(breakpointVariable).replace('px', ''));
      if (isNaN(breakpointWidth)) {
        return false;
      }

      return gridTableWidth.value < breakpointWidth;
    });

    const actionColumn = computed(() => {
      return {
        name: 'action',
        label: '',
        side: 'right',
        gridSize: props.actionsGridSize && !forceMobile.value ? props.actionsGridSize : 'max-content',
      };
    });

    const allColumns = computed(() => props.columns.concat(props.actions.length ? [actionColumn.value] : []));
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
        '--column-count': allColumns.value.length,
        '--desktop-grid-template-columns': forceMobile.value
          ? `repeat(calc(var(--column-count) - 1), auto) ${props.actionsGridSize ?? 'max-content'}`
          : allColumns.value.map(column => (column.gridSize ?? 'auto')).join(' '),
        '--grid-table-left-grid-column': [1, midGridColumn.value].join(' / '),
        '--grid-table-right-grid-column': [midGridColumn.value, -1].join(' / '),
        '--grid-row-content-grid-end': props.actions.length ? -2 : -1,
      };
    });

    const headerLabels = (column => column.label.split('\n'));
    const sortIconFor = (column) => {
      if (props.sorting?.sortColumn === column.sortColumn) {
        return props.sorting?.sortDirection?.toLowerCase() === 'asc' ? 'sort-up' : 'sort-down';
      } else {
        return 'sort';
      }
    }

    const handleSearchInput = searchString => emit('search', searchString);
    const updateGridTableWidth = () => gridTableWidth.value = gridTable.value.offsetWidth;
    const handleSorting = (column) => {
      if (column.sortColumn) {
        emit('sort', column.sortColumn);
      }
    };

    onMounted(() => {
      isMounted.value = true;
      updateGridTableWidth();
      window.addEventListener('resize', updateGridTableWidth);
    });

    onUnmounted(() => {
      isMounted.value = false;
      window.removeEventListener('resize', updateGridTableWidth);
    });

    return {
      t,
      gridTable,
      gridTableStyle,
      forceMobile,
      leftColumns,
      rightColumns,
      sortIconFor,
      headerLabels,
      handleSearchInput,
      handleSorting,
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
  grid-template-columns: var(--desktop-grid-template-columns);
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

  .GridRow--sortable {
    margin: calc(map-get($spacers, 2) * -1) calc(map-get($spacers, 3) * -1);
    padding: map-get($spacers, 2) map-get($spacers, 3) !important;
    width: 100%;

    &:hover, &:active, &:focus {
      background-color: rgba(#808080, 0.15) !important;
      cursor: pointer;
    }
  }
}

.GridTable.rounded .GridRow__header .GridRow--sortable {
  &:hover, &:active, &:focus {
    border-radius: $border-radius;
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
.GridTable.rounded .GridRow__header + .GridRow {
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
.GridTable.rounded .GridRow:last-child {
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

@mixin gridTableMobile() {
  .GridTable {
    grid-template-columns: repeat(var(--column-count), auto);
  }

  .GridRow {
    .GridRow__left > *, .GridRow__right > * {
      grid-column: 1 / -1;
    }

    &.GridRow__header > .GridRow__left > div:not(:first-child) > h5,
    &.GridRow__header > .GridRow__left > div:first-child > h5:not(:first-child),
    &.GridRow__header > .GridRow__right > div:not(:first-child) > h5,
    &.GridRow__header > .GridRow__right > div:first-child > h5:not(:first-child) {
      font-size: $h6-font-size;
      margin-top: map-get($spacers, 1) !important;
    }

    &.GridRow__header > .GridRow__right > div:last-child {
      margin-right: 0;
    }

    .GridRow__left > div:not(:first-child),
    .GridRow__right > div:not(:first-child) {
      color: var(--bs-secondary-color);
      font-size: $h6-font-size;
    }

    .GridRow__left > div {
      text-align: left;
      padding-left: 0;
    }

    .GridRow__right > div {
      text-align: right;
      padding-right: 0;
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
  @include gridTableMobile();

  .GridRow {
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

    &:nth-child(2) > .GridRow__actions > a:last-child {
      border-top-right-radius: $border-radius;
    }

    &:last-child > .GridRow__actions > a:last-child {
      border-bottom-right-radius: $border-radius;
    }

    &.GridRow__header > .GridRow__right {
      grid-column-end: -1 !important;
    }

    .GridRow__content {
      grid-column-end: -1 !important;
      position: relative;
    }
  }
}

@include media-breakpoint-up(lg) {
  // Hover effect for rows that are links
  a.GridRow:hover, a.GridRow.active, a.GridRow.focus,
  div.GridRow--hoverable:hover, div.GridRow--hoverable:active, div.GridRow--hoverable:focus {
    background-color: transparent !important;

    .GridRow__content > * {
      background-color: transparent !important;
    }
  }
}

.GridTable.mobile {
  @include gridTableMobile();

  .GridRow {
    &.GridRow__header > .GridRow__right {
      grid-column-end: -2;
    }
  }
}
</style>
