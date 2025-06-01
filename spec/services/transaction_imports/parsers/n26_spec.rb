# frozen_string_literal: true

RSpec.describe TransactionImports::Parsers::N26, type: :service do
  let(:parser) { described_class.new(import) }
  let(:import) { create(:import, :n26) }

  describe '#parse_file' do
    subject { parser.parse_file.as_json }

    let(:expected_transactions) do
      [
        TransactionImports::ImportTransaction.new(
          import:               import,
          original_import_name: 'amazon.co.uk*DJ43KJFsd',
          name:                 'amazon.co.uk*DJ43KJFsd',
          transaction_date:     Date.parse('2024-12-29'),
          amount:               -6.03,
          wallet_id:            import.wallet.id
        ),
        TransactionImports::ImportTransaction.new(
          import:               import,
          original_import_name: 'TESCO STORES',
          name:                 'TESCO STORES',
          transaction_date:     Date.parse('2024-12-29'),
          amount:               -28.89,
          wallet_id:            import.wallet.id
        ),
        TransactionImports::ImportTransaction.new(
          import:               import,
          original_import_name: 'COSTA',
          name:                 'COSTA',
          transaction_date:     Date.parse('2024-12-29'),
          amount:               -5.65,
          wallet_id:            import.wallet.id
        ),
        TransactionImports::ImportTransaction.new(
          import:               import,
          original_import_name: 'Main Account N26 N26 You Membership Fee',
          name:                 'Main Account N26 N26 You Membership Fee',
          transaction_date:     Date.parse('2024-12-31'),
          amount:               -7.9,
          wallet_id:            import.wallet.id
        ),
        TransactionImports::ImportTransaction.new(
          import:               import,
          original_import_name: 'Main Account Monthly Rule',
          name:                 'Main Account Monthly Rule',
          transaction_date:     Date.parse('2025-01-01'),
          amount:               -300.0,
          wallet_id:            import.wallet.id
        )
      ]
    end

    it { is_expected.to eq expected_transactions.as_json }
  end
end
