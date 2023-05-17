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
  },
});
