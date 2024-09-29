# frozen_string_literal: true

RSpec.describe TransactionImports::Parsers::PTSB, type: :service do
  let(:parser) { described_class.new(import) }
  let(:import) { create(:import, :ptsb) }

  describe '#parse_file' do
    subject { parser.parse_file.as_json }

    let(:expected_transactions) do
      [
        TransactionImports::ImportTransaction.new(
          import:               import,
          original_import_name: 'CNC TESCO STORES',
          name:                 'CNC TESCO STORES',
          transaction_date:     Date.parse('2023-05-03'),
          amount:               -15.25,
          wallet_id:            import.wallet.id
        ),
        TransactionImports::ImportTransaction.new(
          import:               import,
          original_import_name: 'CNC MCDONALDS',
          name:                 'CNC MCDONALDS',
          transaction_date:     Date.parse('2023-05-02'),
          amount:               -8.95,
          wallet_id:            import.wallet.id
        ),
        TransactionImports::ImportTransaction.new(
          import:               import,
          original_import_name: 'CNC TESCO STORES',
          name:                 'CNC TESCO STORES',
          transaction_date:     Date.parse('2023-05-02'),
          amount:               -2.0,
          wallet_id:            import.wallet.id
        ),
        TransactionImports::ImportTransaction.new(
          import:               import,
          original_import_name: 'DD TEST DEBIT',
          name:                 'DD TEST DEBIT',
          transaction_date:     Date.parse('2023-05-03'),
          amount:               -12.34,
          wallet_id:            import.wallet.id
        ),
        TransactionImports::ImportTransaction.new(
          import:               import,
          original_import_name: 'Apr Cash Earned',
          name:                 'Apr Cash Earned',
          transaction_date:     Date.parse('2023-05-02'),
          amount:               5.00,
          wallet_id:            import.wallet.id
        ),
        TransactionImports::ImportTransaction.new(
          import:               import,
          original_import_name: 'PTSB VISA',
          name:                 'PTSB VISA',
          transaction_date:     Date.parse('2023-04-24'),
          amount:               -2.0,
          wallet_id:            import.wallet.id
        )
      ]
    end

    around do |example|
      travel_to(Time.zone.parse('2023-12-31')) { example.run }
    end

    it { is_expected.to eq expected_transactions.as_json }
  end
end
