import { storeToRefs } from 'pinia';

import I18n from '~/utils/I18n.js';
import useProfileStore from '~/stores/ProfileStore.js';

export function formatMoney(amount, options = {}) {
  const defaultOptions = { includeCents: true };
  options = Object.assign(defaultOptions, options);

  const locale = I18n.getLocale();
  const fractionDigits = options.includeCents ? 2 : 0;

  if (!options.currency) {
    const profileStore = useProfileStore();
    const { currentProfile } = storeToRefs(profileStore);

    options.currency = currentProfile.value.currencyObject.isoCode || 'eur';
  }

  const formatOptions = {
    style: 'currency',
    currency: options.currency,
    minimumFractionDigits: fractionDigits,
    maximumFractionDigits: fractionDigits,
    signDisplay: options.signDisplay,
  };

  return Intl.NumberFormat(locale, formatOptions).format(amount).replace(/\s/, '');
}
