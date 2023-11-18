# frozen_string_literal: true

RSpec.describe Importer::Base, type: :service do
  let(:importer) { described_class.new(file_name) }
  let(:file_name) { 'statement.csv' }
  let(:account) { create(:account) }
  let(:user) { account.user }

  before do
    Current.account = account
    Current.user    = user
  end

  describe '#import!' do
    subject(:import) { importer.import! }

    before do
      allow(importer).to receive_messages(source: :n26, parse: parsed_transactions)
    end

    context 'when there are no issues' do
      let(:parsed_transactions) do
        [
          ['Test 1 raw', 'Test 1', 1.day.ago, -4.99],
          ['Test 2 raw', 'Test 2', Time.current, 2]
        ]
      end

      it 'saves the transactions and link them to a new Import record' do
        expect { import }
          .to change { Transaction.count }
          .by(2)
          .and change { Import.count }
          .by(1)
      end

      it 'creates the first transaction correctly' do
        import
        t1 = Transaction.first

        expect(t1.name).to eq 'Test 1'
        expect(t1.raw_import_name).to eq 'Test 1 raw'
        expect(t1.transaction_date).to eq 1.day.ago.to_date
        expect(t1.amount.cents).to eq(-499)
        expect(t1.import).to eq Import.first
      end

      it 'creates the second transaction correctly' do
        import
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
        expect { import }
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
                             account: account)
      end

      it 'does not insert the same transaction again' do
        expect { import }.not_to change { Transaction.count }
      end

      it 'does not insert an Import record since no transactions were imported' do
        expect { import }.not_to change { Import.count }
      end
    end
  end
end
