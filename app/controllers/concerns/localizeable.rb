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
    locale = params[:new_locale] || current_user&.locale || session[:locale]
    locale = I18n.default_locale unless I18n.locale_available?(locale)

    Current.locale = locale.to_s.inquiry
    old_locale     = session[:locale]
    return locale if old_locale == locale

    session[:locale] = locale
    save_user_locale(locale)

    locale
  end

  def save_user_locale(locale)
    return unless current_user

    current_user.update(locale:)
  end
end
