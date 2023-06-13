import I18n from '~/utils/I18n';

export function formatDate(date) {
  return Intl.DateTimeFormat(I18n.getLocale()).format(date);
}
