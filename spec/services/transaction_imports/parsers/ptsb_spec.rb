# frozen_string_literal: true

RSpec.describe TransactionImports::Parsers::PTSB, type: :service do
  let(:parser) { described_class.new(import) }
  let(:import) { create(:import, :ptsb) }

  describe '#parse' do
    subject { parser.parse }

    let(:expected_transactions) do
      [
        TransactionImports::ImportTransaction.new(
          original_import_name: 'CNC TESCO STORES 03/05 1',
          name:                 'CNC TESCO STORES',
          transaction_date:     Date.parse('2023-05-03'),
          amount:               -15.25,
          import_file_index:    0,
          wallet_id:            import.wallet.id
        ),
        TransactionImports::ImportTransaction.new(
          original_import_name: 'CNC MCDONALDS 70 02/05 1',
          name:                 'CNC MCDONALDS',
          transaction_date:     Date.parse('2023-05-02'),
          amount:               -8.95,
          import_file_index:    1,
          wallet_id:            import.wallet.id
        ),
        TransactionImports::ImportTransaction.new(
          original_import_name: 'CNC TESCO STORES 02/05 2',
          name:                 'CNC TESCO STORES',
          transaction_date:     Date.parse('2023-05-02'),
          amount:               -2.0,
          import_file_index:    2,
          wallet_id:            import.wallet.id
        ),
        TransactionImports::ImportTransaction.new(
          original_import_name: 'DD TEST DEBIT',
          name:                 'DD TEST DEBIT',
          transaction_date:     Date.parse('2023-05-03'),
          amount:               -12.34,
          import_file_index:    3,
          wallet_id:            import.wallet.id
        ),
        TransactionImports::ImportTransaction.new(
          original_import_name: 'Apr Cash Earned',
          name:                 'PTSB Cashback',
          transaction_date:     Date.parse('2023-05-02'),
          amount:               5.00,
          import_file_index:    4,
          wallet_id:            import.wallet.id
        ),
        TransactionImports::ImportTransaction.new(
          original_import_name: 'PTSB VISA         123456',
          name:                 'Credit Card',
          transaction_date:     Date.parse('2023-04-24'),
          amount:               -2.0,
          import_file_index:    5,
          wallet_id:            import.wallet.id
        )
      ]
    end

    around do |example|
      travel_to(Time.zone.parse('2023-12-31')) { example.run }
    end

    before do
      create(:import_name, import_name: 'Apr Cash Earned', transaction_name: 'PTSB Cashback', profile: import.profile)
      create(:import_name, import_name: 'PTSB VISA', transaction_name: 'Credit Card', profile: import.profile)
    end

    it { is_expected.to eq expected_transactions }
  end
end
