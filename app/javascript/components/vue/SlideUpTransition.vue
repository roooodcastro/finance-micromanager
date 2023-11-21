<template>
  <Transition
    v-if="!group"
    name="SlideUpTransition"
    tag="div"
    class="overflow-hidden"
  >
    <slot />
  </Transition>

  <TransitionGroup
    v-else
    name="SlideUpTransition"
    tag="div"
    class="overflow-hidden"
    @enter="handleEnter"
    @leave="handleLeave"
  >
    <slot />
  </TransitionGroup>
</template>
<script>

export default {
  components: {
  },

  props: {
    group: {
      type: Boolean,
      default: false,
    },
    skipEnter: {
      type: Boolean,
      default: false,
    },
    skipLeave: {
      type: Boolean,
      default: false,
    },
  },

  setup(props) {
    const handleEnter = (el, done) => {
      if (props.skipEnter) {
        done();
      } else {
        const height = el.offsetHeight;
        el.style.height = 0;
        setTimeout(() => {
          el.style.height = `${height}px`;
        }, 0);
      }
    };

    const handleLeave = (el, done) => {
      if (props.skipLeave) {
        done();
      } else {
        el.style.height = 0;
        el.className = el.className.replace(/\b(mb|my|mt)-.+?/g, '');
      }
    };

    return {
      handleEnter,
      handleLeave,
    };
  },
};
</script>

<style lang="scss">
.SlideUpTransition-move,
.SlideUpTransition-enter-active,
.SlideUpTransition-leave-active {
  transition: all 0.4s ease;
}

.SlideUpTransition-enter-from,
.SlideUpTransition-leave-to {
  transform: translateY(-100%);
  opacity: 0;
}

.SlideUpTransition-leave-to {
  height: 0;
}
</style>
