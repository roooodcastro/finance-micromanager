# frozen_string_literal: true

module CamelizePropsHelper
  def camelize_props(props, options = {})
    CamelizeProps.call(props, options)
  end
end

RSpec.configure do |config|
  config.include CamelizePropsHelper, type: :controller
end
