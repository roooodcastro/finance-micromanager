<template>
  <div class="ProfileAvatar rounded-circle">
    {{ nameInitials }}
  </div>
</template>

<script>
import useUserStore from '~/stores/UserStore.js';

export default {
  setup() {
    const userStore = useUserStore();

    return {
      nameInitials: userStore.nameInitials,
    };
  },
};
</script>

<style lang="scss" scoped>
@import '../../stylesheets/variables';

.ProfileAvatar {
  background-color: $mintgreen-600;
  color: $white;
  font-size: 1.75em;
  font-weight: lighter;
  line-height: 2em;
  margin: 2px;
  height: 2em;
  width: 2em;
  text-align: center;
}
</style>
