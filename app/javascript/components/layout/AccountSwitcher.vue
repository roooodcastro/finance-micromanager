<template>
  <div
    class="btn-group"
  >
    <button
      class="btn AccountSwitcher__button"
      :class="currentAccount ? 'btn-primary' : 'btn-warning'"
      type="button"
      data-bs-toggle="dropdown"
      aria-expanded="false"
      @click="handleDropDownClick"
    >
      <template v-if="currentAccount">
        <FontAwesomeIcon
          class="me-3"
          :icon="iconFor(currentAccount.currency)"
        />
        {{ currentAccount?.currency_object?.name }}
      </template>
      <template v-else>
        {{ t('no_account_selected') }}
      </template>
      <FontAwesomeIcon
        class="ms-3"
        icon="chevron-down"
      />
    </button>
    <ul class="dropdown-menu">
      <li
        v-for="account in availableAccounts"
        :key="account.id"
      >
        <a
          class="dropdown-item AccountSwitcher__account-link"
          :class="{ active: account.id === currentAccount.id }"
          href="#"
        >
          <FontAwesomeIcon
            class="me-3 text-secondary"
            :icon="iconFor(account.currency)"
          />

          {{ account.currency_object.name }}
        </a>
      </li>

      <li>
        <hr class="dropdown-divider my-3">
      </li>

      <li>
        <a
          class="dropdown-item"
          :href="newAccountPath"
        >
          <FontAwesomeIcon
            class="me-3 text-secondary"
            icon="square-plus"
          />
          {{ t('new_account_link') }}
        </a>
      </li>
    </ul>
  </div>
</template>

<script>
import { ref } from 'vue';
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';

import useAccountStore from '~/stores/AccountStore.js';
import { accounts } from '~/api';
import I18n from '@/utils/I18n';

export default {
  components: {
    FontAwesomeIcon,
  },

  setup() {
    const t = I18n.scopedTranslator('views.navigation.account_switcher');

    const accountStore = useAccountStore();
    const currentAccount = accountStore.currentAccount;
    const availableAccounts = accountStore.availableAccounts;
    const dropdownOpened = ref(false);
    const newAccountPath = accounts.new.path();

    const handleDropDownClick = (ev) => {
      dropdownOpened.value = ev.target.classList.contains('show');
    };

    const iconFor = (currencyName) => {
      const iconMapping = {
        eur: 'euro-sign',
        usd: 'dollar-sign',
        brl: 'brazilian-real-sign',
        gbp: 'sterling-sign',
        jpy: 'yen-sign',
      };

      return iconMapping[currencyName] ?? 'wallet';
    };

    return {
      availableAccounts,
      currentAccount,
      dropdownOpened,
      iconFor,
      handleDropDownClick,
      newAccountPath,
      t,
    };
  },
};
</script>

<style lang="scss" scoped>
@import '../../stylesheets/variables';

.AccountSwitcher__button svg:last-child {
  transition: all 0.25s;
  transform: rotate(0deg);
}

.AccountSwitcher__button.show svg:last-child {
  transform: rotate(180deg);
}

.AccountSwitcher__account-link.active svg {
  color: $white !important;
}
</style>
