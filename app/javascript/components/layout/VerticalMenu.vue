<template>
  <div
    class="offcanvas offcanvas-start"
    id="verticalMenu"
    aria-labelledby="mainMenuLabel"
  >
    <div class="offcanvas-header">
      <h5
        class="offcanvas-title"
        id="mainMenuLabel"
      >
        Main Menu
      </h5>
      <button
        type="button"
        class="btn-close"
        data-bs-dismiss="offcanvas"
        aria-label="Close"
      />
    </div>
    <div class="offcanvas-body px-0">
      <div class="list-group">
        <a
          v-for="menuItem in menuItems"
          :key="menuItem.label"
          :href="menuItem.path"
          class="list-group-item list-group-item-action"
          :class="{ active: menuItem.active }"
        >
          {{ menuItem.label }}
        </a>
      </div>
    </div>
  </div>
</template>

<script>
import { transactions, categories } from '~/api';

export default {
  setup() {
    const menuItems = [
      { label: 'Dashboard', path: transactions.list.path() },
      { label: 'Categories', path: categories.list.path() },
    ];

    menuItems.forEach((menuItem) => {
      if (window.location.pathname.includes(menuItem.path)) {
        menuItem['active'] = true;
      }
    })

    return {
      menuItems,
    };
  },
}
</script>
