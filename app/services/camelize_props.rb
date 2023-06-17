# frozen_string_literal: true

class CamelizeProps
  attr_reader :props, :options

  def self.call(props, options = {})
    new(props, options).call
  end

  def initialize(props, options)
    @props   = props
    @options = options
  end

  def call
    camelize_mode = options.fetch(:camelize_mode, :deep)

    process_props(props, camelize_mode)
  end

  def process_props(props, camelize_mode)
    case camelize_mode
    when :deep
      props.deep_transform_keys { |key| fast_camelize(key.to_s) }
    when :root
      props.transform_keys { |key| fast_camelize(key.to_s) }
    else
      props
    end
  end

  def fast_camelize(key)
    return '' if key.blank?

    transformed_key = key.gsub(%r{(?:_|(/))([a-z\d]*)}i) do
      "#{Regexp.last_match(1)}#{Regexp.last_match(2).capitalize}"
    end

    transformed_key[0] = transformed_key[0].downcase
    transformed_key
  end
end
