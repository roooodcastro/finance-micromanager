# frozen_string_literal: true

class WalletBalanceSyncQuery < ApplicationQuery
  bind :profile_id, :uuid
  bind :end_date, :date

  WalletBalance = Struct.new(:wallet_id, :amount_cents, :currency) do
    def amount
      Money.from_cents(amount_cents, currency).to_f
    end
  end

  def wrapper_class
    WalletBalance
  end

  def base_query
    <<~SQL.squish
      SELECT
        t.wallet_id,
        SUM(t.amount_cents) + COALESCE(rw.balance_amount_cents, 0) AS amount_cents,
        p.currency
      FROM transactions AS t
      INNER JOIN profiles AS p ON p.id = t.profile_id
      LEFT JOIN reconciliations AS r ON r.profile_id = p.id AND r.status = '#{Reconciliation.statuses[:finished]}'
      LEFT JOIN reconciliations_wallets AS rw ON rw.wallet_id = t.wallet_id AND rw.reconciliation_id = r.id
      WHERE
        t.profile_id = @profile_id
        AND (r.date IS NULL OR t.transaction_date > r.date)
        AND (r.date IS NULL OR r.date = (
          SELECT MAX(date)
          FROM reconciliations
          WHERE profile_id = @profile_id
        ))
        #{end_date_condition}
      GROUP BY t.wallet_id, rw.balance_amount_cents, p.currency
    SQL
  end

  private

  def end_date_condition
    return '' unless end_date

    'AND t.transaction_date <= @end_date'
  end
end
