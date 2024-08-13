# frozen_string_literal: true

module Transactions
  class SyncProfileAndWalletBalances < ApplicationService
    attr_reader :profile

    def initialize(profile:)
      super()
      @profile = profile
    end

    def call
      ActiveRecord::Base.transaction do
        wallets.each { |wallet| wallet.update!(balance_cents: wallet_balances[wallet.id].amount_cents) }
        profile.update!(balance_amount_cents: wallet_balances.values.pluck(:amount_cents).sum)
      end
    end

    private

    def wallet_balances
      @wallet_balances ||= WalletBalanceSyncQuery
                           .run(profile_id: profile.id)
                           .index_by(&:wallet_id)
    end

    def wallets
      @wallets ||= Wallet.where(id: wallet_balances.values.pluck(:wallet_id).compact)
    end
  end
end
