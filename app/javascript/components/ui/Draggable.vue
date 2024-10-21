<template>
  <div
    ref="rootElement"
    @mousemove="handleDrag"
  >
    <slot />
  </div>
</template>

<script>
import { onMounted, onUnmounted, ref } from 'vue';

export default {
  props: {
    draggableElementSelector: {
      type: String,
      default: null,
    },
    triggerElementSelector: {
      type: String,
      default: null,
    },
  },

  setup(props) {
    const dragging = ref(false);

    const elementOffsetX = ref(0);
    const elementOffsetY = ref(0);
    const maxOffsetX = ref(0);
    const maxOffsetY = ref(0);

    const rootElement = ref(null);
    const triggerElement = ref(null);
    const draggableElement = ref(null);

    onMounted(() => {
      triggerElement.value = props.triggerElementSelector
        ? rootElement.value.querySelector(props.triggerElementSelector)
        : rootElement.value;

        triggerElement.value.addEventListener('mousedown', handleDragStart);
        triggerElement.value.style['cursor'] = 'grab';
    });

    onUnmounted(() => {
      triggerElement.value.removeEventListener('mousedown', handleDragStart);
    })

    const handleDragStart = (ev) => {
      if (ev.button === 0 && ev.buttons === 1) {
        dragging.value = true;
        triggerElement.value.style['cursor'] = 'grabbing';
        draggableElement.value = props.draggableElementSelector
          ? rootElement.value.querySelector(props.draggableElementSelector)
          : rootElement.value;

        // Calculate bounding box
        maxOffsetX.value = document.body.getBoundingClientRect().width;
        maxOffsetY.value = document.body.getBoundingClientRect().height;
      }
    };

    const handleDrag = (ev) => {
      if (dragging.value && draggableElement.value) {
        // Handle the end of the drag, when the mouse button is released
        if (ev.buttons === 0) {
          dragging.value = false;
          triggerElement.value.style['cursor'] = 'grab';
        }

        const elementPosX = draggableElement.value.getBoundingClientRect().x;
        const elementPosY = draggableElement.value.getBoundingClientRect().y;

        let moveX = ev.movementX;
        let moveY = ev.movementY;

        const containerWidth = draggableElement.value.offsetWidth;
        const containerHeight = draggableElement.value.offsetHeight;

        const finalPosX = elementPosX + moveX;
        const finalPosY = elementPosY + moveY;

        // Stop overflow to the left
        if (finalPosX < 0) {
          moveX -= finalPosX;
        }

        // Stop overflow to the right
        if ((finalPosX + containerWidth) > maxOffsetX.value) {
          const diff = maxOffsetX.value - (finalPosX + containerWidth);
          moveX += diff;
        }

        // Stop overflow to the top
        if (finalPosY < 0) {
          moveY -= finalPosY;
        }

        // Stop overflow to the bottom
        if ((finalPosY + containerHeight) > maxOffsetY.value) {
          const diff = maxOffsetY.value - (finalPosY + containerHeight);
          moveY += diff;
        }

        elementOffsetX.value += moveX;
        elementOffsetY.value += moveY;

        draggableElement.value.style['transform'] = `translate(${elementOffsetX.value}px, ${elementOffsetY.value}px)`;
      }
    };

    return {
      rootElement,
      handleDrag,
    }
  },
};
</script>
