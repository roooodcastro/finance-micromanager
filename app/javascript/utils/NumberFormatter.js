import { storeToRefs } from 'pinia';

import I18n from '~/utils/I18n.js';
import useProfileStore from '~/stores/ProfileStore.js';

export function formatMoney(amount, currency = null, includeCents = true) {
  const locale = I18n.getLocale();
  const fractionDigits = includeCents ? 2 : 0;

  if (!currency) {
    const profileStore = useProfileStore();
    const { currentProfile } = storeToRefs(profileStore);

    currency = currentProfile.value.currencyObject.isoCode || 'eur';
  }

  const formatOptions = {
    style: 'currency',
    currency,
    minimumFractionDigits: fractionDigits,
    maximumFractionDigits: fractionDigits,
  };

  return Intl.NumberFormat(locale, formatOptions).format(amount);
}
