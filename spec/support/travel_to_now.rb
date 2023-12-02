# frozen_string_literal: true

RSpec.configure do |config|
  config.include ActiveSupport::Testing::TimeHelpers

  config.around(:each, :travel_to_now) do |example|
    target_time = respond_to?(:now) ? now : Time.current.change(usec: 0)
    travel_to(target_time) { example.run }
  end
end
