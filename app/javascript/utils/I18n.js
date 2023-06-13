import { I18n as I18nJs } from "i18n-js";

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
    return (scope, options) => this.i18n.t(scope, { ...options, scope: rootScope });
  }

  async loadTranslations() {
    const locale = document.querySelector('meta[name="locale"]')?.content;
    const response = await fetch(`/locales/${locale}.json`);
    const translations = await response.json();

    this.i18n.locale = locale;
    this.i18n.store(translations);
  }
}

export default new I18n();
