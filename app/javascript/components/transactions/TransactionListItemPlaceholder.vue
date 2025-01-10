<template>
  <div class="d-flex justify-content-between align-items-center flex-grow-1">
    <div class="side-strip side-strip-light placeholder-glow flex-grow-1 ps-3 py-2">
      <div class="d-flex justify-content-between flex-grow-1 fs-4 mb-2">
        <span class="placeholder col-6" />
        <span class="placeholder col-1" />
      </div>
      <div class="d-flex justify-content-between flex-grow-1">
        <span class="placeholder col-3" />
        <span class="placeholder col-3" />
      </div>
    </div>

    <div class="placeholder-glow d-none d-lg-flex pe-3">
      <div class="vr mx-3" />
      <span class="placeholder TransactionListItemPlaceholder__action-button" />
      <div class="vr mx-3" />
      <span class="placeholder TransactionListItemPlaceholder__action-button" />
    </div>
  </div>
</template>

<style lang="scss" scoped>
.TransactionListItemPlaceholder__action-button {
  width: 1.25rem;
  height: 1.25rem;
}
</style>
