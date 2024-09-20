# frozen_string_literal: true

RSpec.describe TransactionImports::BaseParser, type: :service do
  let(:parser) { described_class.new(import) }
  let(:profile) { create(:profile) }
  let(:wallet) { create(:wallet) }
  let(:user) { profile.user }
  let(:import) { create(:import, profile:, wallet:) }

  before do
    Current.profile = profile
    Current.user    = user
  end

  describe 'self.parser_for' do
    subject(:parser_for) { described_class.parser_for(import) }

    let(:import) { build(:import, source:, profile:) }

    context 'when passing an import for PTSB' do
      let(:source) { :ptsb }

      it { is_expected.to be_an_instance_of(TransactionImports::Parsers::PTSB) }
    end

    context 'when passing an import for N26' do
      let(:source) { :n26 }

      it { is_expected.to be_an_instance_of(TransactionImports::Parsers::N26) }
    end

    context 'when passing an import for Revolut' do
      let(:source) { :revolut }

      it { is_expected.to be_an_instance_of(TransactionImports::Parsers::Revolut) }
    end

    context 'when passing an import for an unsupported source' do
      let(:source) { :ptsb }

      before { allow(import).to receive(:source).and_return('unsupported') }

      it 'raises an error' do
        expect { parser_for }.to raise_error(ArgumentError, 'Import source unknown: unsupported')
      end
    end
  end

  describe '#parse!', :aggregate_failures do
    subject(:parse!) { parser.parse! }

    let(:import_transactions) do
      [
        TransactionImports::ImportTransaction.new(
          original_import_name: 'Raw 1', name: 'Test 1', amount: -4.99,
          transaction_date: '2024-08-16', wallet: wallet, import: import
        ),
        TransactionImports::ImportTransaction.new(
          original_import_name: 'Raw 2', name: 'Test 2', amount: -33.00,
          transaction_date: '2024-08-15', wallet: wallet, import: import
        ),
        TransactionImports::ImportTransaction.new(
          original_import_name: 'Raw 3', name: 'Test 3', amount: 2.00,
          transaction_date: '2024-08-14', wallet: wallet, import: import
        )
      ]
    end

    before { allow(parser).to receive(:parse_file).and_return(import_transactions) }

    context 'when no further processing is needed' do
      it 'saves the transaction_imports' do
        expect { parse! }.to change { TransactionImports::ImportTransaction.count }.by(3)
        expect(import_transactions[0]).to be_persisted
        expect(import_transactions[0].action).to eq('import')
        expect(import_transactions[1]).to be_persisted
        expect(import_transactions[1].action).to eq('import')
        expect(import_transactions[2]).to be_persisted
        expect(import_transactions[2].action).to eq('import')
      end
    end

    context 'when there are transaction matches' do
      let!(:matching_transaction1) do
        create(:transaction, profile: profile, wallet: wallet, transaction_date: '2024-08-15', amount: -33)
      end

      let!(:matching_transaction2) do
        create(:transaction, profile: profile, wallet: wallet, transaction_date: '2024-08-14', amount: 2,
          import: create(:import))
      end

      it 'saves the transaction_imports and assign correct attributes' do
        expect { parse! }.to change { TransactionImports::ImportTransaction.count }.by(3)

        # No match
        expect(import_transactions[0]).to be_persisted
        expect(import_transactions[0].action).to eq('import')

        # Valid match
        expect(import_transactions[1]).to be_persisted
        expect(import_transactions[1].action).to eq('match')
        expect(import_transactions[1].match_transaction).to eq(matching_transaction1)

        # Matching an already imported transaction - skip and don't match
        expect(import_transactions[2]).to be_persisted
        expect(import_transactions[2].action).to eq('skip')
        expect(import_transactions[2].match_transaction).not_to eq(matching_transaction2)
      end
    end

    context 'when the transaction is from before the last reconciliation date' do
      before do
        create(:reconciliation, :finished, profile: profile, date: '2024-08-20')
        profile.reload
      end

      it 'saves the transaction_imports and assign action to all as blocked' do
        expect { parse! }.to change { TransactionImports::ImportTransaction.count }.by(3)
        expect(import_transactions[0]).to be_persisted
        expect(import_transactions[0].action).to eq('block')
        expect(import_transactions[1]).to be_persisted
        expect(import_transactions[1].action).to eq('block')
        expect(import_transactions[2]).to be_persisted
        expect(import_transactions[2].action).to eq('block')
      end
    end

    context 'when some transaction predictions apply' do
      let(:rules_json) do
        {
          conditions: [
            {
              operator: :equals,
              column:   'name',
              value:    'Test 2'
            }
          ],
          actions:    [
            {
              column: 'category_id',
              value:  subcategory.compose_category_id
            },
            {
              column: 'wallet_id',
              value:  other_wallet.id
            }
          ]
        }
      end

      let(:category) { create(:category, profile:) }
      let(:subcategory) { create(:subcategory, category:) }
      let(:other_wallet) { create(:wallet, profile:) }

      before { create(:transaction_prediction, profile: profile, rules_json: rules_json.to_json) }

      it 'saves the transaction_imports and assigns category to some' do
        expect { parse! }.to change { TransactionImports::ImportTransaction.count }.by(3)
        expect(import_transactions[0]).to be_persisted
        expect(import_transactions[0].category).to be_nil
        expect(import_transactions[0].wallet).to eq(wallet)
        expect(import_transactions[1]).to be_persisted
        expect(import_transactions[1].category).to eq(category)
        expect(import_transactions[1].subcategory).to eq(subcategory)
        expect(import_transactions[1].wallet).to eq(wallet)
        expect(import_transactions[2]).to be_persisted
        expect(import_transactions[2].category).to be_nil
        expect(import_transactions[2].wallet).to eq(wallet)
      end
    end

    context 'when there is an error saving something' do
      let(:import_transactions) do
        [
          TransactionImports::ImportTransaction.new(
            original_import_name: 'Raw 1', name: 'Test 1', amount: -4.99,
            transaction_date: '2024-08-16', wallet: wallet, import: import
          ),
          TransactionImports::ImportTransaction.new(
            original_import_name: 'Raw 2', name: 'Test 2', amount: -33.00,
            transaction_date: '2024-08-15', wallet: wallet, import: import
          ),
          TransactionImports::ImportTransaction.new(
            original_import_name: nil, name: nil, amount: nil, transaction_date: nil, wallet: nil, import: nil
          )
        ]
      end

      it 'does not save anything' do
        expect { parse! }.to not_change { TransactionImports::ImportTransaction.count }
      end
    end
  end
end
