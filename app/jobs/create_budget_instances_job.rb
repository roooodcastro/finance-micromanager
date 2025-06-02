# frozen_string_literal: true

require 'sidekiq-scheduler'

class CreateBudgetInstancesJob < ApplicationJob
  queue_as :default

  def perform
    Budgets::CreateBudgetInstancesService.call
  end
end
