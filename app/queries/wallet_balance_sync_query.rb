# frozen_string_literal: true

class WalletBalanceSyncQuery < ApplicationQuery
  bind :profile_id, :uuid

  def self.unspecified_balance_amount(profile:)
    results      = run(profile_id: profile.id)
    amount_cents = results.find { |result| result['wallet_id'].nil? }&.dig('amount_cents')
    return 0 unless amount_cents

    Money.from_cents(amount_cents, profile.currency).to_f
  end

  def base_query
    <<~SQL.squish
      SELECT
        t.wallet_id,
        SUM(t.amount_cents) + COALESCE(rw.balance_amount_cents, 0) AS amount_cents
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
      GROUP BY t.wallet_id, rw.balance_amount_cents
    SQL
  end
end
