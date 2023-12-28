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
        transaction = create_balance_transaction!
        reconciliation.update!(status: :finished, balance_correction_transaction: transaction)
        Transactions::SyncProfileAndWalletBalances.call(profile:)
      rescue ActiveRecord::ActiveRecordError
        raise ActiveRecord::Rollback
      end
    end

    def balance_difference
      wallets_real_balance - wallets_calculated_balance
    end

    private

    # This will also update the profile balance to the correct sum of balance from all wallets.
    def create_balance_transaction!
      return if balance_difference.to_f.zero?

      profile.transactions.create!(
        name:             'reconciliations.transaction_name',
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

    def wallets_calculated_balance
      @wallets_calculated_balance ||= ReconciliationWalletBalancesQuery
                                      .run(reconciliation_id: reconciliation.id)
                                      .map(&:amount)
                                      .sum
    end

    def wallets_real_balance
      @wallets_real_balance ||= reconciliations_wallets.sum(&:balance_amount).to_f
    end

    def category_for_transaction
      Category.reconciliation_category_for(profile)
    end
  end
end
