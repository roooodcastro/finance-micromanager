# frozen_string_literal: true

RSpec::Matchers.define :include_camelized_props do |expected_props|
  match do |inertia|
    camelized_expected_props = CamelizeProps.call(expected_props).deep_symbolize_keys

    # Computed props have symbolized keys.
    expect(inertia.props).to include camelized_expected_props
  end

  failure_message do |inertia|
    camelized_expected_props = CamelizeProps.call(expected_props.deep_symbolize_keys)
    received_props           = inertia.props || 'nothing'

    "expected camelized inertia props to include #{camelized_expected_props}, instead received #{received_props}"
  end
end
