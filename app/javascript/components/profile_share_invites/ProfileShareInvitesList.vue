<template>
  <div>
    <SlideUpTransition group>
      <ProfileShareInviteReceived
        v-for="invite in profileShareInvitesReceived"
        :key="`${invite.id}_received_${invite.status}`"
        :profile-share-invite="invite"
        class="overflow-hidden"
        @accepted="handleReceivedInviteResponse(invite, true)"
        @rejected="handleReceivedInviteResponse(invite, false)"
      />
    </SlideUpTransition>

    <SlideUpTransition group>
      <ProfileShareInviteSent
        v-for="invite in profileShareInvitesSent"
        :key="`${invite.id}_sent_${invite.status}`"
        :profile-share-invite="invite"
        class="overflow-hidden"
        @cancelled="handleSentInviteCancellation(invite)"
      />
    </SlideUpTransition>
  </div>
</template>

<script>
import { storeToRefs } from 'pinia';

import useProfileStore from '~/stores/ProfileStore.js';
import useProfileShareInviteStore from '~/stores/ProfileShareInviteStore.js';
import ProfileShareInviteReceived from '~/components/profile_share_invites/ProfileShareInviteReceived.vue';
import ProfileShareInviteSent from '~/components/profile_share_invites/ProfileShareInviteSent.vue';
import SlideUpTransition from '~/components/vue/SlideUpTransition.vue';

const RESPONSE_MESSAGE_TIMEOUT = 5000;

export default {
  components: {
    SlideUpTransition,
    ProfileShareInviteReceived,
    ProfileShareInviteSent,
  },

  setup() {
    const profileShareInviteStore = useProfileShareInviteStore();
    const profileStore = useProfileStore();
    const { profileShareInvitesReceived, profileShareInvitesSent } = storeToRefs(profileShareInviteStore);
    profileShareInviteStore.fetchPendingReceivedInvites();
    profileShareInviteStore.fetchPendingSentInvites();

    const handleReceivedInviteResponse = (profileShareInvite, accepted) => {
      if (accepted) {
        profileShareInviteStore.acceptPendingReceivedInvite(profileShareInvite).then(() => {
          profileStore.fetchCollection();
          setTimeout(() => {
            profileShareInviteStore.removeProfileShareInviteReceived(profileShareInvite);
          }, RESPONSE_MESSAGE_TIMEOUT);
        });
      } else {
        profileShareInviteStore.rejectPendingReceivedInvite(profileShareInvite).then(() => {
          setTimeout(() => {
            profileShareInviteStore.removeProfileShareInviteReceived(profileShareInvite);
          }, RESPONSE_MESSAGE_TIMEOUT);
        });
      }
    };

    const handleSentInviteCancellation = (profileShareInvite) => {
      profileShareInviteStore.cancelPendingSentInvite(profileShareInvite).then(() => {
        setTimeout(() => {
          profileShareInviteStore.removeProfileShareInviteSent(profileShareInvite);
        }, RESPONSE_MESSAGE_TIMEOUT);
      });
    };

    return {
      profileShareInvitesReceived,
      profileShareInvitesSent,
      handleReceivedInviteResponse,
      handleSentInviteCancellation,
    };
  },
};
</script>
