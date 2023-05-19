<template>
  <div>
    <div
      v-for="(message, index) in successMessages"
      :key="`success_${index}`"
      class="alert alert-success alert-dismissible"
    >
      {{ message }}
      <CloseButton />
    </div>

    <div
      v-for="(message, index) in warningMessages"
      :key="`warning_${index}`"
      class="alert alert-warning alert-dismissible"
    >
      <strong>Warning:</strong>
      {{ message }}
      <CloseButton />
    </div>

    <div
      v-for="(message, index) in errorMessages"
      :key="`error_${index}`"
      class="alert alert-danger alert-dismissible"
    >
      <strong>Error:</strong>
      {{ message }}
      <CloseButton />
    </div>
  </div>
</template>

<script>
import CloseButton from '~/components/bootstrap/CloseButton.vue';

export default {
  components: {
    CloseButton,
  },

  props: {
    flashMessages: {
      type: Object,
      required: true,
    },
  },

  setup(props) {
    const successMessages = ([props.flashMessages?.success] || []).concat([props.flashMessages?.notice] || []).flat().filter(Boolean);
    const warningMessages = ([props.flashMessages?.warning] || []).flat().filter(Boolean);
    const errorMessages = ([props.flashMessages?.error] || []).concat([props.flashMessages?.alert] || []).flat().filter(Boolean);

    return {
      successMessages,
      warningMessages,
      errorMessages,
    };
  }
};
</script>
