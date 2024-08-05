# frozen_string_literal: true

RSpec.describe TransactionImports::Parsers::N26, type: :service do
  let(:parser) { described_class.new(import) }
  let(:import) { create(:import, :n26) }

  describe '#parse' do
    subject { parser.parse }

    let(:expected_transactions) do
      [
        TransactionImports::ImportTransaction.new(
          original_import_name: 'NETFLIX.COM',
          name:                 'NETFLIX.COM',
          transaction_date:     Date.parse('2023-04-07'),
          amount:               -20.0,
          import_file_index:    0,
          wallet_id:            import.wallet.id
        ),
        TransactionImports::ImportTransaction.new(
          original_import_name: 'From Test Space to Main Wallet',
          name:                 'From Test Space to Main Wallet',
          transaction_date:     Date.parse('2023-04-12'),
          amount:               100.0,
          import_file_index:    1,
          wallet_id:            import.wallet.id
        ),
        TransactionImports::ImportTransaction.new(
          original_import_name: 'WWW.ALIEXPRESS.COM',
          name:                 'WWW.ALIEXPRESS.COM',
          transaction_date:     Date.parse('2023-04-13'),
          amount:               -9.99,
          import_file_index:    2,
          wallet_id:            import.wallet.id
        )
      ]
    end

    it { is_expected.to eq expected_transactions }
  end
end
