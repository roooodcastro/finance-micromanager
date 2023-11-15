import { defineStore } from 'pinia'

export default defineStore('user', {
  state: () => ({
    user: null,
  }),
  getters: {
    isUserLoggedIn: (state) => !!state.user,
    displayName: (state) => {
      if (!state.user) return '';

      return state.user.firstName ?? state.user.email;
    },
    fullName: (state) => {
      if (!state.user) return '';

      return [state.user.firstName, state.user.lastName].join(' ').trim();
    },
    nameInitials: (state) => {
      if (!state.user) return '';

      const fullName = [state.user.firstName, state.user.lastName].join(' ').trim();
      const fullNameParts = fullName.split(' ');

      if (fullNameParts.length > 1) {
        return [
          fullNameParts[0].slice(0, 1),
          fullNameParts[fullNameParts.length - 1].slice(0, 1)
        ].join('').toUpperCase();
      } else {
        return state.user.email.slice(0, 2).toUpperCase();
      }
    },
  },
});
