import { defineStore } from 'pinia'

export default defineStore('user', {
  state: () => ({
    user: null,
  }),
  getters: {
    isUserLoggedIn: (state) => !!state.user,
    nameInitials: (state) => {
      if (!state.user) return '';

      const fullNameParts = state.user.fullName.split(' ');

      if (fullNameParts.length >= 1) {
        return fullNameParts[0].slice(0, 1).toUpperCase();
      } else {
        return state.user.email.slice(0, 1).toUpperCase();
      }
    },
  },
});
