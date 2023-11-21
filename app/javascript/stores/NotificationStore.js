import { defineStore } from 'pinia'

export default defineStore('notifications', {
  state: () => ({
    notifications: [],
  }),

  actions: {
    loadFromProps(newNotifications) {
      const variantMap = {
        'notice': 'success',
        'alert': 'danger',
        'error': 'danger',
      };

      this.notifications = Object.keys(newNotifications).flatMap((variant) => {
        return { 'variant': variantMap[variant] || variant, 'message': newNotifications[variant] }
      });
    },
  },
});
