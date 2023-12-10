<template>
  <div ref="scrollContainer">
    <slot />
  </div>
</template>

<script>
import { ref, onMounted, onUnmounted } from 'vue';

export default {
  emits: ['scroll'],

  setup(_, { emit }) {
    const scrollContainer = ref(null);

    const handleScroll = () => {
      if (scrollContainer.value.getBoundingClientRect().bottom < window.innerHeight) {
        emit('scroll');
      }
    };

    onMounted(() => {
      document.querySelector('#app').addEventListener('scroll', handleScroll);
    });

    onUnmounted(() => {
      document.querySelector('#app').removeEventListener('scroll', handleScroll);
    });

    return {
      scrollContainer,
    }
  },
};
</script>
