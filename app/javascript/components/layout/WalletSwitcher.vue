<template>
  <div
    class="btn-group"
  >
    <button
      class="btn WalletSwitcher__button"
      :class="currentWallet ? 'btn-primary' : 'btn-warning'"
      type="button"
      data-bs-toggle="dropdown"
      aria-expanded="false"
      @click="handleDropDownClick"
    >
      <template v-if="currentWallet">
        <FontAwesomeIcon
          class="me-3"
          :icon="faIconForCurrency(currentWallet.currency)"
        />
        {{ currentWallet?.displayName }}
      </template>
      <template v-else>
        {{ t('no_wallet_selected') }}
      </template>
      <FontAwesomeIcon
        class="ms-3"
        icon="chevron-down"
      />
    </button>
    <ul class="dropdown-menu">
      <li
        v-for="wallet in availableWallets"
        :key="wallet.id"
      >
        <a
          class="dropdown-item WalletSwitcher__wallet-link"
          :class="{ active: wallet.id === currentWallet.id }"
          href="#"
          @click="handleWalletChange(wallet.id)"
        >
          <FontAwesomeIcon
            class="WalletSwitcher__currency-icon me-2 text-secondary"
            :icon="faIconForCurrency(wallet.currency)"
          />

          <FontAwesomeIcon
            v-if="wallet.shared"
            class="me-2 text-primary"
            icon="share-nodes"
          />

          {{ wallet.displayName }}
        </a>
      </li>

      <li>
        <hr class="dropdown-divider my-2">
      </li>

      <li>
        <a
          class="dropdown-item"
          :href="newWalletPath"
        >
          <FontAwesomeIcon
            class="WalletSwitcher__currency-icon me-2 text-secondary"
            icon="square-plus"
          />
          {{ t('new_wallet_link') }}
        </a>
      </li>
    </ul>
  </div>
</template>

<script>
import { ref } from 'vue';
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';
import { storeToRefs } from 'pinia';

import useWalletStore from '~/stores/WalletStore.js';
import useFlashStore from '~/stores/FlashStore.js';
import { wallets, currentWallets } from '~/api';
import { faIconForCurrency } from '~/utils/CurrencyIcons.js';
import I18n from '~/utils/I18n';

export default {
  components: {
    FontAwesomeIcon,
  },

  setup() {
    const t = I18n.scopedTranslator('views.layout.wallet_switcher');

    const walletStore = useWalletStore();
    const { currentWallet, availableWallets } = storeToRefs(walletStore);
    const dropdownOpened = ref(false);
    const newWalletPath = wallets.new.path();

    const handleWalletChange = (walletId) => {
      currentWallets
        .create({ data: { wallet_id: walletId } })
        .then((response) => {
          if (response.error) {
            const { errorMessages } = storeToRefs(useFlashStore());
              errorMessages.value.push(response.error);
          } else {
            currentWallet.value = response.wallet;
          }
        });
    };

    const handleDropDownClick = (ev) => {
      dropdownOpened.value = ev.target.classList.contains('show');
    };

    return {
      availableWallets,
      currentWallet,
      dropdownOpened,
      faIconForCurrency,
      handleWalletChange,
      handleDropDownClick,
      newWalletPath,
      t,
    };
  },
};
</script>

<style lang="scss" scoped>
@import '../../stylesheets/variables';

.WalletSwitcher__button svg:last-child {
  transition: all 0.25s;
  transform: rotate(0deg);
}

.WalletSwitcher__button.show svg:last-child {
  transform: rotate(180deg);
}

.WalletSwitcher__wallet-link.active svg {
  color: $white !important;
}

.WalletSwitcher__currency-icon {
  width: 2em;
}
</style>
