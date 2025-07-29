# frozen_string_literal: true

RSpec.describe TransactionImports::ImportTransactionProcessors::DefaultActionSetter, type: :service do
  describe 'self.call' do
    subject(:call) { described_class.call(import, import_transactions) }

    let(:profile) { create(:profile) }
    let(:import) { create(:import, :in_progress, profile:) }
    let(:import_transactions) { [import_transaction] }
    let(:import_transaction) { build(:import_transaction, import:) }

    context 'when action is currently nil' do
      let(:import_transaction) do
        build(:import_transaction, import: import, original_import_name: 'original', name: 'original')
      end

      before { create(:import_name, profile: profile, import_name: 'other', transaction_name: 'transaction name') }

      it 'does not change the import_transaction name' do
        expect { call }.not_to change { import_transaction.name }
      end
    end

    context 'when action is already import' do
      let(:import_transaction) { build(:import_transaction, import: import, action: 'import') }

      it 'does not change the action' do
        expect { call }.not_to change { import_transaction.action }
      end
    end

    context 'when action is already skip' do
      let(:import_transaction) { build(:import_transaction, import: import, action: 'skip') }

      it 'does not change the action' do
        expect { call }.not_to change { import_transaction.action }
      end
    end

    context 'when action is already match' do
      let(:import_transaction) { build(:import_transaction, import: import, action: 'match') }

      let(:transaction) { create(:transaction, profile:).attributes.symbolize_keys }

      before { import_transaction.matches = [{ transaction: }] }

      it 'does not change the action' do
        expect { call }.not_to change { import_transaction.action }
      end
    end

    context 'when action is already import but now it should be blocked' do
      let(:import_transaction) do
        build(:import_transaction, import: import, action: 'import', transaction_date: '2024-09-20')
      end

      before do
        create(:reconciliation, :finished, profile: profile, date: '2024-09-30')
        import.reload
      end

      it 'changes the action to blocked' do
        expect { call }.to change { import_transaction.action }.to('block')
      end
    end

    context 'when action is nil and there are no possible matches' do
      let(:import_transaction) { build(:import_transaction, import: import, action: nil) }

      it 'sets the action to import' do
        expect { call }.to change { import_transaction.action }.to('import')
      end
    end

    context 'when action is nil and the top match has already been imported' do
      let(:import_transaction) { build(:import_transaction, import: import, action: nil) }
      let(:transaction) { create(:transaction, profile:, import:) }

      before { import_transaction.matches = [{ transaction: transaction, already_imported: true }] }

      it 'sets the action to skip' do
        expect { call }.to change { import_transaction.action }.to('skip')
      end
    end

    context 'when action is nil and the top match is already matched with a different import_transaction' do
      let(:import_transaction) { build(:import_transaction, import: import, action: nil) }
      let(:other_import_transaction) { create(:import_transaction) }
      let(:transaction) do
        create(:transaction, profile: profile, import: import, import_transaction: other_import_transaction)
          .attributes
          .symbolize_keys
          .merge(import_transaction_id: other_import_transaction.id)
      end

      before { import_transaction.matches = [{ transaction: transaction, already_imported: true }] }

      it 'sets the action to import and does not change any other attribute' do
        expect { call }
          .to change { import_transaction.action }
          .to('import')
          .and not_change { import_transaction.name }
          .and not_change { import_transaction.transaction_date }
          .and not_change { import_transaction.category }
          .and not_change { import_transaction.amount.to_f }
      end
    end

    context 'when action is nil and there is a valid match' do
      let(:import_transaction) { build(:import_transaction, import: import, action: nil, name: 'Test') }
      let(:transaction) do
        create(:transaction, profile: profile, import: import, amount: 4, transaction_date: 1.day.ago)
          .attributes
          .symbolize_keys
      end

      before { import_transaction.matches = [{ transaction: transaction, already_imported: false }] }

      it 'sets the action to match and set attributes from the transaction' do
        expect { call }
          .to change { import_transaction.action }
          .to('match')
          .and change { import_transaction.name }
          .to(transaction[:name])
          .and not_change { import_transaction.transaction_date }
          .and change { import_transaction.category_id }
          .to(transaction[:category_id])
          .and not_change { import_transaction.amount.to_f }
      end
    end

    context 'when action is match but the top match is already matched with a different import_transaction' do
      let(:import_transaction) do
        build(
          :import_transaction,
          import:               import,
          action:               'match',
          name:                 'Matching name',
          original_import_name: 'Original',
          category:             category,
          subcategory:          create(:subcategory, category:)
        )
      end

      let(:category) { create(:category, profile:) }
      let(:other_import_transaction) { create(:import_transaction) }

      let(:transaction) do
        create(:transaction, profile: profile, import_transaction: other_import_transaction)
          .attributes
          .symbolize_keys
          .merge(import_transaction_id: other_import_transaction.id)
      end

      before { import_transaction.matches = [{ transaction: }] }

      it 'sets the action to import and resets the attributes' do
        expect { call }
          .to change { import_transaction.action }
          .to('import')
          .and change { import_transaction.name }
          .to('Original')
          .and not_change { import_transaction.transaction_date }
          .and change { import_transaction.category }
          .to(nil)
          .and change { import_transaction.subcategory }
          .to(nil)
          .and not_change { import_transaction.amount.to_f }
      end
    end

    context 'when action is nil and it should be blocked' do
      let(:import_transaction) do
        build(:import_transaction, import: import, action: nil, transaction_date: '2024-09-20')
      end

      before do
        create(:reconciliation, :finished, profile: profile, date: '2024-09-30')
        import.reload
      end

      it 'changes the action to blocked' do
        expect { call }.to change { import_transaction.action }.to('block')
      end
    end

    context 'when action is changing from match to import' do
      let(:import_transaction) do
        build(:import_transaction, import: import, action: 'import', match_transaction: transaction)
      end

      let(:transaction) { create(:transaction, profile:) }

      it 'resets the match_transaction to nil' do
        expect { call }.to change { import_transaction.match_transaction }.to(nil)
      end
    end
  end
end
