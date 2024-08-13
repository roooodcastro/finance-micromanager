# frozen_string_literal: true

class ApplicationService
  def self.call(...)
    new(...).call
  end

  def initialize(...); end

  def call
    raise NotImplementedError
  end
end
