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

    context 'when passing an import for an unsupported source' do
      let(:source) { :ptsb }

      before { allow(import).to receive(:source).and_return('unsupported') }

      it 'raises an error' do
        expect { parser_for }.to raise_error(ArgumentError, 'Import source unknown: unsupported')
      end
    end
  end

  describe '.generate_preview', :travel_to_now do
    subject { parser.generate_preview }

    let(:parsed_transactions) do
      [
        TransactionImports::ImportTransaction.new(original_import_name: 'Raw 1', name: 'Test 1', amount: -4.99,
                                                  transaction_date: Date.parse('2024-06-26'), wallet_id: wallet.id),
        TransactionImports::ImportTransaction.new(original_import_name: 'Raw 2', name: 'Test 2', amount: 2,
                                                  transaction_date: Date.parse('2024-06-28'), wallet_id: wallet.id),
        TransactionImports::ImportTransaction.new(original_import_name: 'Raw 3', name: 'Test 3', amount: -3,
                                                  transaction_date: Date.parse('2024-06-19'), wallet_id: wallet.id)
      ]
    end

    let!(:matched_transaction) { create(:transaction, name: 'Test 2', amount: 2, profile: profile) }

    let(:expected_preview_data) do
      [
        {
          id:                   '59c7ee34-04aa-5bd6-a72c-de812bdd128f',
          original_import_name: 'Raw 1',
          name:                 'Test 1',
          transaction_date:     '2024-06-26',
          amount:               -4.99,
          wallet_id:            wallet.id,
          action_id:            :import,
          matches:              []
        },
        {
          id:                   '58462647-b77f-5276-a9c7-7cc529e2c583',
          original_import_name: 'Raw 2',
          name:                 'Test 2',
          transaction_date:     '2024-06-28',
          amount:               2,
          wallet_id:            wallet.id,
          action_id:            :match,
          matches:              [{ transaction: matched_transaction.as_json, match_score: 2 }]
        },
        {
          id:                   '4d3c5190-3081-52f2-852e-a829a8e2f199',
          original_import_name: 'Raw 3',
          name:                 'Test 3',
          transaction_date:     '2024-06-19',
          amount:               -3,
          wallet_id:            wallet.id,
          action_id:            :block,
          matches:              []
        }
      ]
    end

    before do
      create(:reconciliation, :finished, profile: profile, date: '2024-06-24')
      profile.reload
      allow(parser).to receive(:parse).and_return(parsed_transactions)
    end

    it { is_expected.to eq expected_preview_data.as_json }
  end

  describe '#import!', skip: 'refactor' do
    subject(:import!) { parser.import! }

    before do
      allow(parser).to receive_messages(source: :n26, parse: parsed_transactions)
    end

    context 'when there are no issues' do
      let(:parsed_transactions) do
        [
          ['Test 1 raw', 'Test 1', 1.day.ago, -4.99],
          ['Test 2 raw', 'Test 2', Time.current, 2]
        ]
      end

      it 'saves the transactions and link them to a new Import record' do
        expect { import! }
          .to change { Transaction.count }
          .by(2)
          .and change { Import.count }
          .by(1)
      end

      it 'creates the first transaction correctly' do
        import!
        t1 = Transaction.first

        expect(t1.name).to eq 'Test 1'
        expect(t1.raw_import_name).to eq 'Test 1 raw'
        expect(t1.transaction_date).to eq 1.day.ago.to_date
        expect(t1.amount.cents).to eq(-499)
        expect(t1.import).to eq Import.first
      end

      it 'creates the second transaction correctly' do
        import!
        t2 = Transaction.last

        expect(t2.name).to eq 'Test 2'
        expect(t2.raw_import_name).to eq 'Test 2 raw'
        expect(t2.transaction_date).to eq Time.current.to_date
        expect(t2.amount.cents).to eq(200)
        expect(t2.import).to eq Import.first
      end
    end

    context 'when there is an error in one of the transactions' do
      let(:parsed_transactions) do
        [
          ['Test 1 raw', 'Test 1', 1.day.ago, 4.99],
          ['Test 2 raw', 'Test 2', nil, nil]
        ]
      end

      it 'does not save anything' do
        expect { import! }
          .to not_change { Transaction.count }
          .and not_change { Import.count }
      end
    end

    context 'when a transaction has already been imported before' do
      let(:parsed_transactions) do
        [['Test 1 raw', 'Test 1', 1.day.ago, -4.99]]
      end

      before do
        create(:transaction, name: 'Test 1', raw_import_name: 'Test 1 raw', transaction_date: 1.day.ago, amount: -4.99,
               profile: profile)
      end

      it 'does not insert the same transaction again' do
        expect { import! }.not_to change { Transaction.count }
      end

      it 'does not insert an Import record since no transactions were imported' do
        expect { import! }.not_to change { Import.count }
      end
    end
  end
end
