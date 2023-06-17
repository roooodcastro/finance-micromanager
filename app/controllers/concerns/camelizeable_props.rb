# frozen_string_literal: true

module CamelizeableProps
  extend ActiveSupport::Concern

  def camelize_props(props, options = {})
    CamelizeProps.call(props, options)
  end
end
