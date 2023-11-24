# frozen_string_literal: true

module JsonResponse
  def json_response
    @json_response ||= JSON.parse(response.body)
  end
end

RSpec.configure do |config|
  config.include JsonResponse, type: :controller
end
