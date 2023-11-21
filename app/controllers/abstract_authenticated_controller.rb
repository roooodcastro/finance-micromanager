# frozen_string_literal: true

class AbstractAuthenticatedController < ApplicationController
  before_action :authenticate_user!

  inertia_share user: -> { camelize_props(current_user.as_json) }
  inertia_share currentWallet: -> { camelize_props(Current.wallet.as_json) }
  inertia_share availableWallets: -> { current_user.available_wallets.as_json.map(&method(:camelize_props)) }
end
