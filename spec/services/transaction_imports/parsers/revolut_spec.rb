# frozen_string_literal: true

RSpec.describe TransactionImports::Parsers::Revolut, type: :service do
  let(:parser) { described_class.new(import) }
  let(:import) { create(:import, :revolut) }

  describe '#parse_file' do
    subject { parser.parse_file.as_json }

    let(:expected_transactions) do
      [
        TransactionImports::ImportTransaction.new(
          import:               import,
          original_import_name: 'Transfer from My Friend',
          name:                 'Transfer from My Friend',
          transaction_date:     Date.parse('2024-07-30'),
          amount:               10.0,
          wallet_id:            import.wallet.id
        ),
        TransactionImports::ImportTransaction.new(
          import:               import,
          original_import_name: 'Supermarket',
          name:                 'Supermarket',
          transaction_date:     Date.parse('2024-07-26'),
          amount:               -25.6,
          wallet_id:            import.wallet.id
        )
      ]
    end

    it { is_expected.to eq expected_transactions.as_json }
  end
end
