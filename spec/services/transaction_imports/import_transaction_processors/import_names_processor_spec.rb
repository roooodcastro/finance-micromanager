# frozen_string_literal: true

RSpec.describe TransactionImports::ImportTransactionProcessors::ImportNamesProcessor, type: :service do
  describe 'self.call' do
    subject(:call) { described_class.call(import, import_transactions) }

    let(:profile) { create(:profile) }
    let(:import) { create(:import, :in_progress, profile:) }
    let(:import_transactions) { [import_transaction] }

    context 'when no import_name matches' do
      let(:import_transaction) do
        create(:import_transaction, import: import, original_import_name: 'original', name: 'original')
      end

      before { create(:import_name, profile: profile, import_name: 'other', transaction_name: 'transaction name') }

      it 'does not change the import_transaction name' do
        expect { call }.not_to change { import_transaction.name }
      end
    end

    context 'when at least one import_name match an import_transaction' do
      before { create(:import_name, profile: profile, import_name: 'original', transaction_name: 'transaction name') }

      context 'and the import_transaction is still using the original import name' do
        let(:import_transaction) do
          create(:import_transaction, import: import, original_import_name: 'original', name: 'original')
        end

        it 'updates the import_transaction name according to the import_name' do
          expect { call }.to change { import_transaction.name }.to('transaction name')
        end
      end

      context 'and the import_transaction is using a custom name' do
        let(:import_transaction) do
          create(:import_transaction, import: import, original_import_name: 'original', name: 'new name')
        end

        it 'does not change the import_transaction name' do
          expect { call }.not_to change { import_transaction.name }
        end
      end
    end
  end
end
