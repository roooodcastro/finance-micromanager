<template>
  <div>
    <h6 class="text-center mb-3">
      Or, you can also:
    </h6>

    <div class="d-grid gap-3">
      <a
        v-if="showSessionLink"
        :href="newSessionPath"
        class="btn btn-light btn-sm"
      >
        Sign In
      </a>

      <a
        v-if="showRegistrationLink"
        :href="newRegistrationPath"
        class="btn btn-light btn-sm"
      >
        Sign Up
      </a>

      <a
        v-if="showPasswordLink"
        :href="newPasswordPath"
        class="btn btn-light btn-sm"
      >
        Forgot your password?
      </a>

      <a
        v-if="showUnlockLink"
        :href="newUnlockPath"
        class="btn btn-light btn-sm"
      >
        Didn't receive unlock instructions?
      </a>

      <a
        v-if="showConfirmationLink"
        :href="newConfirmationPath"
        class="btn btn-light btn-sm"
      >
        Didn't receive confirmation instructions?
      </a>
    </div>
  </div>
</template>

<script>
import { usersConfirmations, usersSessions, usersRegistrations, usersPasswords, usersUnlocks } from '~/api';

export default {
  props: {
    page: {
      type: String,
      required: true,
    },
  },
  setup(props) {
    const newConfirmationPath = usersConfirmations.new.path();
    const newPasswordPath = usersPasswords.new.path();
    const newRegistrationPath = usersRegistrations.new.path();
    const newSessionPath = usersSessions.new.path();
    const newUnlockPath = usersUnlocks.new.path();

    const showConfirmationLink = props.page === 'registrations';
    const showPasswordLink = props.page === 'sessions';
    const showRegistrationLink = props.page !== 'registrations';
    const showSessionLink = props.page !== 'sessions';
    const showUnlockLink = props.page === 'sessions';

    return {
      newConfirmationPath,
      newPasswordPath,
      newRegistrationPath,
      newSessionPath,
      newUnlockPath,
      showConfirmationLink,
      showPasswordLink,
      showRegistrationLink,
      showSessionLink,
      showUnlockLink,
    };
  },
}
</script>
