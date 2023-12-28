# frozen_string_literal: true

class WalletBalanceSyncQuery < ApplicationQuery
  bind :profile_id, :uuid

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
        w.id AS wallet_id,
        COALESCE(SUM(t.amount_cents), 0) + COALESCE(rw.balance_amount_cents, 0) AS amount_cents,
        p.currency
      FROM wallets AS w
      INNER JOIN profiles AS p ON p.id = w.profile_id
      LEFT JOIN reconciliations AS r
        ON r.profile_id = @profile_id AND r.status = '#{Reconciliation.statuses[:finished]}'
      LEFT JOIN reconciliations_wallets AS rw ON rw.wallet_id = w.id AND rw.reconciliation_id = r.id
      LEFT JOIN transactions AS t ON t.wallet_id = w.id AND (r.id IS NULL OR t.transaction_date > r.date)
      WHERE
        w.profile_id = @profile_id
        AND w.disabled_at IS NULL
        AND (r.date IS NULL OR r.date = (
          SELECT MAX(date)
          FROM reconciliations
          WHERE profile_id = @profile_id
          AND status = '#{Reconciliation.statuses[:finished]}'
        ))
      GROUP BY w.id, rw.balance_amount_cents, p.currency

      UNION ALL

      SELECT
        NULL,
        SUM(t.amount_cents),
        p.currency
      FROM transactions AS t
      INNER JOIN profiles AS p ON p.id = t.profile_id
      LEFT JOIN reconciliations AS r
        ON r.profile_id = @profile_id AND r.status = '#{Reconciliation.statuses[:finished]}'
      WHERE
        t.profile_id = @profile_id
        AND t.wallet_id IS NULL
        AND (r.id IS NULL OR t.transaction_date > r.date)
        AND (r.date IS NULL OR r.date = (
          SELECT MAX(date)
          FROM reconciliations
          WHERE profile_id = @profile_id
          AND status = '#{Reconciliation.statuses[:finished]}'
        ))
      GROUP BY p.currency
    SQL
  end
end
