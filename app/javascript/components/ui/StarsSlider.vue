<template>
  <div>
    <FontAwesomeIcon
      v-for="(icon, index) in starIcons"
      :key="index"
      :icon="icon"
    />
  </div>
</template>

<script>
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';

const EMPTY_STAR_ICON = ['far', 'star'];
const HALF_STAR_ICON = 'star-half-stroke';
const FULL_STAR_ICON = 'star';

export default {
  components: {
    FontAwesomeIcon,
  },

  props: {
    max: {
      type: Number,
      default: 5,
    },

    value: {
      type: Number,
      required: true,
    },
  },

  setup(props) {
    const starIcons = [...Array(props.max)].map((_, index) => {
      const indexRef = (index + 1) * 2;
      const valueRef = Math.round(props.value * 2);

      if (valueRef === indexRef - 1) {
        return HALF_STAR_ICON;
      } else if (valueRef < indexRef) {
        return EMPTY_STAR_ICON;
      }
      return FULL_STAR_ICON;
    });

    return {
      starIcons,
    };
  },
};
</script>
