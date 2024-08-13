# frozen_string_literal: true

module Transactions
  class UpdateAssociatedBalances < ApplicationService
    attr_reader :transaction, :operation

    def initialize(transaction, operation)
      super()
      @transaction = transaction
      @operation   = operation
    end

    def call
      update_profile_balance!
      update_wallet_balance!
    end

    private

    def update_profile_balance!
      transaction.profile.update!(balance_amount: transaction.profile.balance_amount + amount_difference)
    end

    def update_wallet_balance! # rubocop:disable Metrics/AbcSize
      if wallet_changing_from_nil?
        transaction.wallet.update!(balance: transaction.wallet.balance + transaction.amount)
      elsif wallet_changing_to_another?
        old_wallet.update!(balance: old_wallet.balance - old_amount)
        transaction.wallet.update!(balance: transaction.wallet.balance + transaction.amount)
      elsif wallet_changing_to_nil?
        old_wallet.update!(balance: old_wallet.balance - old_amount)
      elsif transaction.wallet
        transaction.wallet.update!(balance: transaction.wallet.balance + amount_difference)
      end
    end

    def old_wallet
      return @old_wallet if defined?(@old_wallet)

      @old_wallet = begin
        old_wallet_id = transaction.changes.dig(:wallet_id, 0)
        Wallet.find(old_wallet_id) if old_wallet_id
      end
    end

    def wallet_changing_from_nil?
      return false unless transaction.changes[:wallet_id]

      transaction.changes.dig(:wallet_id, 0).nil? && transaction.changes.dig(:wallet_id, 1).present?
    end

    def wallet_changing_to_another?
      return false unless transaction.changes[:wallet_id]

      transaction.changes.dig(:wallet_id, 0).present? && transaction.changes.dig(:wallet_id, 1).present?
    end

    def wallet_changing_to_nil?
      return false unless transaction.changes[:wallet_id]

      transaction.changes.dig(:wallet_id, 0).present? && transaction.changes.dig(:wallet_id, 1).nil?
    end

    def old_amount
      return Money.from_cents(0, transaction.amount.currency) unless transaction.persisted?

      amount_changes = transaction.changes.fetch(:amount_cents, [])
      Money.from_cents(amount_changes.fetch(0, transaction.amount_cents), transaction.amount.currency)
    end

    def new_amount
      amount_changes = transaction.changes.fetch(:amount_cents, [])
      Money.from_cents(amount_changes.fetch(1, transaction.amount_cents), transaction.amount.currency)
    end

    def amount_difference
      return -transaction.amount if operation == :destroy

      new_amount - old_amount
    end
  end
end
