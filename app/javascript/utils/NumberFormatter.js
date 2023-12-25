import I18n from '~/utils/I18n.js';

export function formatMoney(amount, currency) {
  const locale = I18n.getLocale();
  return Intl.NumberFormat(locale, { style: 'currency', currency }).format(amount);
}
