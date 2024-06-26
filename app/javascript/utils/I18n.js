import { I18n as I18nJs } from 'i18n-js';

class I18n {
  constructor() {
    this.i18n = new I18nJs();
  }

  getLocale() {
    return this.i18n.locale;
  }

  t(scope, data) {
    return this.i18n.t(scope, data);
  }

  scopedTranslator(rootScope) {
    return (scope, options = {}) => this.i18n.t(scope, Object.assign({ scope: rootScope }, options));
  }

  async loadTranslations() {
    const locale = document.querySelector('meta[name="locale"]')?.content;
    const localeFilePath = document.querySelector('meta[name="locale-file-path"]')?.content;
    const response = await fetch(localeFilePath);
    const translations = await response.json();

    this.i18n.locale = locale;
    this.i18n.store(translations);
  }
}

export default new I18n();
