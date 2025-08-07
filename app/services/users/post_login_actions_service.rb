# frozen_string_literal: true

module Users
  class PostLoginActionsService < ApplicationService
    attr_reader :user

    def initialize(user)
      @user = user
    end

    def call
      user.profiles.each { |profile| Budgets::CreateBudgetInstancesService.call_for_profile(profile) }
    end
  end
end
