# frozen_string_literal: true

class ReconciliationWalletBalancesQuery < ApplicationQuery
  bind :reconciliation_id, :uuid

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
      FROM reconciliations AS r
      INNER JOIN profiles AS p ON p.id = r.profile_id
      LEFT JOIN wallets AS w ON w.profile_id = p.id AND w.disabled_at IS NULL
      LEFT JOIN reconciliations AS fr
        ON fr.profile_id = p.id AND fr.status = '#{Reconciliation.statuses[:finished]}' AND fr.date < r.date
      LEFT JOIN reconciliations_wallets AS rw ON rw.wallet_id = w.id AND rw.reconciliation_id = fr.id
      LEFT JOIN transactions AS t
        ON t.profile_id = p.id
        AND t.transaction_date <= r.date
        AND (fr.date IS NULL OR t.transaction_date > fr.date)
        AND t.wallet_id = w.id
      WHERE
        r.id = @reconciliation_id
        AND (fr.date IS NULL OR fr.date = (
          SELECT MAX(date)
          FROM reconciliations
          WHERE profile_id = r.profile_id
          AND status = '#{Reconciliation.statuses[:finished]}'
          AND date < r.date
        ))
      GROUP BY w.id, rw.balance_amount_cents, p.currency

      UNION ALL

      SELECT
        t.wallet_id,
        COALESCE(SUM(t.amount_cents), 0),
        p.currency
      FROM reconciliations AS r
      INNER JOIN profiles AS p ON p.id = r.profile_id
      LEFT JOIN reconciliations AS fr
        ON fr.profile_id = p.id AND fr.status = '#{Reconciliation.statuses[:finished]}' AND fr.date < r.date
      LEFT JOIN transactions AS t
        ON t.profile_id = p.id
        AND t.transaction_date <= r.date
        AND (fr.date IS NULL OR t.transaction_date > fr.date)
        AND t.wallet_id IS NULL
      WHERE
        r.id = @reconciliation_id
        AND (r.balance_correction_transaction_id IS NULL OR t.id <> r.balance_correction_transaction_id)
        AND (fr.date IS NULL OR fr.date = (
          SELECT MAX(date)
          FROM reconciliations
          WHERE profile_id = r.profile_id
          AND status = '#{Reconciliation.statuses[:finished]}'
          AND date < r.date
        ))
      GROUP BY t.wallet_id, p.currency
    SQL
  end
end
