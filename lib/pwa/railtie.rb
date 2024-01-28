# frozen_string_literal: true

require 'erubi'
require 'rails/railtie'

module Pwa
  class Railtie < Rails::Railtie
    railtie_name :pwa

    SOURCE_MANIFEST_PATH = 'app/views/layouts/manifest.webmanifest.erb'
    TARGET_MANIFEST_PATH = 'app/javascript/entrypoints/manifest.webmanifest'

    if Rails.env.development?
      # Allows to automatically trigger code generation after updating routes.
      initializer 'pwa.reloader' do |app|
        app.config.to_prepare do
          template_path     = Rails.root.join(SOURCE_MANIFEST_PATH)
          compiled_template = Erubi::Engine.new(File.read(template_path), filename: template_path).src
          manifest          = ApplicationController.helpers.instance_eval(compiled_template)

          Rails.root.join(TARGET_MANIFEST_PATH).write(manifest)
        end
      end
    end
  end
end
