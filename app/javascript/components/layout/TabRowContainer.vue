<template>
  <template v-if="shouldExpand">
    <div class="row">
      <div
        v-for="tab, index in tabs"
        :key="index"
        class="col"
        :class="tab.colClasses"
      >
        <component
          :is="noCardWhenExpanded ? 'div' : 'BCard'"
          :no-body="!noCardWhenExpanded && tab.noBodyOnCard"
          :full-height="!noCardWhenExpanded && tab.fullHeight"
        >
          <slot
            :name="tab.slot"
            :is-tab-layout="false"
          />
        </component>
      </div>
    </div>
  </template>

  <template v-else>
    <BCard no-body>
      <div class="TabRowContainer p-2 rounded">
        <ul class="nav nav-pills row text-center mx-0">
          <li
            v-for="tab, index in tabs"
            :key="index"
            class="col nav-item active me-0 p-0"
          >
            <a
              class="TransactionTypeTabs__link nav-link"
              :class="{ 'active': index === selectedTabIndex }"
              href="#"
              @click="handleTabChange(index)"
            >
              {{ tab.title }}
            </a>
          </li>
        </ul>
      </div>

      <div :class="{ 'm-3': !tabs[selectedTabIndex].noBodyOnCard }">
        <slot
          :name="tabs[selectedTabIndex].slot"
          :is-tab-layout="true"
        />
      </div>
    </BCard>
  </template>
</template>

<script>
import { onMounted, onUnmounted, ref } from 'vue';

import { isMediaBreakpointUp } from '~/utils/ResponsivenessUtils.js';

import BCard from '~/components/bootstrap/BCard.vue';

export default {
  components: { BCard },

  props: {
    tabs: {
      type: Array,
      required: true,
    },
    expandFromBreakpoint: {
      type: String,
      default: 'md',
    },
    noCardWhenExpanded: {
      type: Boolean,
      default: false,
    },
  },

  setup(props) {
    const selectedTabIndex = ref(0);
    const shouldExpand = ref('');

    const handleTabChange = tabIndex => selectedTabIndex.value = tabIndex;
    const handleResize = () => shouldExpand.value = isMediaBreakpointUp(props.expandFromBreakpoint);

    onMounted(() => {
      shouldExpand.value = isMediaBreakpointUp(props.expandFromBreakpoint);

      window.addEventListener('resize', handleResize);
    });

    onUnmounted(() => {
      window.remnoveEventListener('resize', handleResize);
    })

    return {
      selectedTabIndex,
      shouldExpand,
      handleTabChange,
    };
  },
};
</script>

<style lang="scss" scoped>
@import '../../stylesheets/variables';

.TabRowContainer {
  background-color: var(--bs-tertiary-bg);
}
</style>
