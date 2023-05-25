# frozen_string_literal: true

Rails.application.config.after_initialize do
  if Rails.env.development?
    require 'i18n-js/listen'

    I18nJS.listen(config_file: Rails.root.join('config/i18n-js.yml'))
  end
end
