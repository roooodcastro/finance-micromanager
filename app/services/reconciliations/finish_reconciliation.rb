# frozen_string_literal: true

module Reconciliations
  class FinishReconciliation < ApplicationService
    attr_reader :reconciliation

    delegate :profile, to: :reconciliation

    def self.call(reconciliation)
      new(reconciliation).call
    end

    def initialize(reconciliation)
      super()
      @reconciliation = reconciliation
    end

    def call
      Reconciliation.transaction do
        update_wallet_balances!
        create_balance_transaction!

        reconciliation.update!(status: :finished)
      rescue ActiveRecord::ActiveRecordError
        raise ActiveRecord::Rollback
      end
    end

    private

    def update_wallet_balances!
      reconciliations_wallets.each do |reconciliation_wallet|
        reconciliation_wallet.wallet.update!(balance: reconciliation_wallet.balance_amount)
      end
    end

    # This will also update the profile balance to the correct sum of balance from all wallets.
    def create_balance_transaction!
      return if balance_difference.to_f.zero?

      profile.transactions.create!(
        name:             I18n.t('reconciliations.transaction_name'),
        category:         category_for_transaction,
        wallet:           nil,
        amount:           balance_difference,
        transaction_date: reconciliation.date,
        created_by:       profile.user,
        updated_by:       profile.user
      )
    end

    def reconciliations_wallets
      @reconciliations_wallets ||= reconciliation.reconciliations_wallets.includes(:wallet)
    end

    def new_profile_balance
      reconciliations_wallets.sum(&:balance_amount)
    end

    def balance_difference
      new_profile_balance - profile.balance_amount
    end

    def category_for_transaction
      profile.categories.first
    end
  end
end
