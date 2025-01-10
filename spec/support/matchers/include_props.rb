# frozen_string_literal: true

RSpec::Matchers.define :include_props do |expected_props|
  match do |inertia|
    # Computed props have symbolized keys.
    expect(inertia.props).to include expected_props.symbolize_keys
  end

  failure_message do |inertia|
    received_props           = inertia.props || 'nothing'

    "expected inertia props to include #{expected_props.symbolize_keys}, instead received #{received_props}"
  end
end
