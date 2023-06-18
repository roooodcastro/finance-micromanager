# frozen_string_literal: true

module Localizeable
  extend ActiveSupport::Concern

  included do
    around_action :switch_locale
  end

  def switch_locale(&)
    I18n.with_locale(fetch_locale, &)
  end

  private

  def fetch_locale
    locale = params[:new_locale] || session[:locale]
    locale = I18n.default_locale unless I18n.locale_available?(locale)

    Current.locale   = locale.to_s.inquiry
    session[:locale] = locale

    locale
  end
end
