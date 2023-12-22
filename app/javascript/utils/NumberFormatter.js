import I18n from '~/utils/I18n.js';

/**
 * Parse a localized number to a float.
 * Copied from https://stackoverflow.com/a/29273131/753012
 * @param {string} stringNumber - the localized number
 */
export function parseLocaleNumber(stringNumber) {
  const locale = I18n.getLocale();
  const thousandSeparator = Intl.NumberFormat(locale).format(11111).replace(/\p{Number}/gu, '');
  const decimalSeparator = Intl.NumberFormat(locale).format(1.1).replace(/\p{Number}/gu, '');

  return parseFloat(stringNumber
    .replace(new RegExp('\\' + thousandSeparator, 'g'), '')
    .replace(new RegExp('\\' + decimalSeparator), '.')
  );
}

export function formatMoney(amount, currency) {
  const locale = I18n.getLocale();
  return Intl.NumberFormat(locale, { style: 'currency', currency }).format(amount);
}
