# frozen_string_literal: true

class AbstractAuthenticatedController < ApplicationController
  before_action :authenticate_user!

  inertia_share user: -> { current_user }
  inertia_share currentAccount: -> { Current.account }
  inertia_share availableAccounts: -> { current_user.accounts.active }
end
