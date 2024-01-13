# frozen_string_literal: true

require 'sidekiq-scheduler'

class ProcessTransactionAutomationsJob < ApplicationJob
  queue_as :default

  def perform
    TransactionAutomations::ProcessTransactionAutomations.new(Date.current).call
  end
end
