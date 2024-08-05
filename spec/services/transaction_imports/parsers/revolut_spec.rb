# frozen_string_literal: true

RSpec.describe TransactionImports::Parsers::Revolut, type: :service do
  let(:parser) { described_class.new(import) }
  let(:import) { create(:import, :revolut) }

  describe '#parse' do
    subject { parser.parse }

    let(:expected_transactions) do
      [
        TransactionImports::ImportTransaction.new(
          original_import_name: 'TRANSFER From My Friend',
          name:                 'Transfer from My Friend',
          transaction_date:     Date.parse('2024-07-30'),
          amount:               10.0,
          import_file_index:    0,
          wallet_id:            import.wallet.id
        ),
        TransactionImports::ImportTransaction.new(
          original_import_name: 'CARD_PAYMENT Supermarket',
          name:                 'Supermarket',
          transaction_date:     Date.parse('2024-07-26'),
          amount:               -25.6,
          import_file_index:    1,
          wallet_id:            import.wallet.id
        )
      ]
    end

    it { is_expected.to eq expected_transactions }
  end
end
