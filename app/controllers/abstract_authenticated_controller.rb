# frozen_string_literal: true

class AbstractAuthenticatedController < ApplicationController
  before_action :authenticate_user!

  inertia_share user: -> { camelize_props(current_user.as_json) }
  inertia_share currentAccount: -> { camelize_props(Current.account.as_json) }
  inertia_share availableAccounts: -> { current_user.accounts.active.as_json.map(&method(:camelize_props)) }
end
