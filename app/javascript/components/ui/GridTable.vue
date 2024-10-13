<template>
  <div
    class="GridTable border rounded"
    :style="gridTableStyle"
  >
    <div class="GridRow GridRow__header">
      <div class="GridRow__left">
        <div
          v-for="header in leftHeaders"
          :key="header.name"
          :class="{ 'text-end': header.align === 'right' }"
        >
          <h5
            v-for="(label, index) in headerLabels(header)"
            :key="`header_left_label_${index}`"
            class="d-block m-0"
          >
            {{ label }}
          </h5>
        </div>
      </div>

      <div class="GridRow__right">
        <div
          v-for="header in rightHeaders"
          :key="header.name"
          :class="{ 'text-end': header.align === 'right' }"
        >
          <h5
            v-for="(label, index) in headerLabels(header)"
            :key="`header_right_label_${index}`"
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
      <component
        :is="!!row.href ? 'a' : 'div'"
        :href="row.href"
        class="GridRow"
        :class="{ 'text-decoration-none link-dark': !!row.href }"
        :style="gridRowStyle(row)"
      >
        <slot :row="row" />
      </component>
    </template>
  </div>
</template>

<script>
import { computed } from 'vue';

export default {
  props: {
    headers: {
      type: Array,
      required: true,
    },
    rows: {
      type: Array,
      required: true,
    },
  },

  setup(props) {
    const numColumns = computed(() => props.headers.length);
    const midGridColumn = computed(() => Math.floor(numColumns.value / 2) + 1);
    const gridTableStyle = computed(() => {
      return {
        'grid-template-columns': props.headers.map(header => (header.gridSize ?? 'auto')).join(' '),
        '--grid-table-left-grid-column': [1, midGridColumn.value].join(' / '),
        '--grid-table-right-grid-column': [midGridColumn.value, -1].join(' / '),
      };
    });

    const gridRowStyle = (row) => {
      return {
        '--grid-table-row-side-strip-color': row.sideStripColor ?? 'transparent',
        'padding-left': row.sideStripColor ? '1.5rem' : '1rem',
      };
    };

    const leftHeaders = computed(() => props.headers.filter(header => header.side === 'left'));
    const rightHeaders = computed(() => props.headers.filter(header => header.side === 'right'));

    const headerLabels = (header => header.label.split('\n'));

    return {
      gridTableStyle,
      gridRowStyle,
      leftHeaders,
      rightHeaders,
      headerLabels,
    };
  }
}
</script>

// eslint-disable-next-line vue-scoped-css/enforce-style-type
<style lang="scss">
@import '../../stylesheets/variables';

.GridTable {
  background-color: $border-color;
  display: grid;
  grid-template-columns: auto auto auto auto;
  align-items: center;
}

.GridRow {
  background-color: $foreground-color;
  border-top: 1px solid $border-color;
  display: grid;
  grid-template-columns: subgrid;
  grid-column: 1 / -1;
  padding: map-get($spacers, 2) map-get($spacers, 3);
  position: relative;

  &:first-child {
    border-top: none;
  }
}

a.GridRow:hover, a.GridRow.active, a.GridRow.focus {
  background-color: rgba(map-get($theme-colors, 'dark'), 0.05);
}

.GridRow:not(.GridRow__header)::before {
  content: '';
  position: absolute;
  left: 0;
  top: 0;
  height: 100%;
  width: $side-strip-width;
  background-color: var(--grid-table-row-side-strip-color);
}

.GridRow:nth-child(2) {
  border-top-left-radius: $border-radius;
  border-top-right-radius: $border-radius;
  &::before {
    border-top-left-radius: $border-radius;
  }
}

.GridRow:last-child {
  border-bottom-left-radius: $border-radius;
  border-bottom-right-radius: $border-radius;
  &::before {
    border-bottom-left-radius: $border-radius;
  }
}

.GridRow__left, .GridRow__right {
  align-items: center;
  display: grid;
  grid-template-columns: subgrid;
}

.GridRow__left {
  grid-column: var(--grid-table-left-grid-column);
}

.GridRow__right {
  grid-column: var(--grid-table-right-grid-column);
}

.GridRow__left > div, .GridRow__right > div {
  padding: 0 map-get($spacers, 2);

  &:first-child {
      padding-left: 0;
    }

    &:last-child {
      padding-right: 0;
    }
}

.GridRow__header {
  font-weight: bold;
  background-color: transparent;
  color: $text-muted;
}

.GridRow__header > .GridRow__left > div > h5:not(:first-child),
.GridRow__header > .GridRow__right > div > h5:not(:first-child) {
  font-size: $h6-font-size;
  margin-top: map-get($spacers, 1) !important;
}

.GridRow__header span {
  white-space: pre;
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

  .GridRow:not(.GridRow__header) > .GridRow__left > div:not(:first-child),
  .GridRow:not(.GridRow__header) > .GridRow__right > div:not(:first-child) {
    color: $text-muted;
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
</style>
