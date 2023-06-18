# frozen_string_literal: true

class LocalesController < ApplicationController
  def index
    locales_list = I18n.available_locales.each_with_object([]) do |locale, result|
      I18n.with_locale(locale) do
        result << { locale: locale, name: I18n.t('locale_name') }
      end
    end

    render json: locales_list
  end
end
