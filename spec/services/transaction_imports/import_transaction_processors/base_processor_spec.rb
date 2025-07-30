# frozen_string_literal: true

RSpec.describe TransactionImports::ImportTransactionProcessors::BaseProcessor, type: :service do
  describe 'self.run_pipeline' do
    subject(:run_pipeline) { described_class.run_pipeline(import, import_transactions, save:) }

    let(:import) { instance_double(Import) }
    let(:import_transactions) do
      [instance_double(TransactionImports::ImportTransaction, save: true, has_changes: true)]
    end
    let(:save) { true }

    context 'when save is true' do
      let(:save) { true }

      it 'runs the pipeline and saves the import transactions' do
        expect(import_transactions[0]).to receive(:save)

        expect(TransactionImports::ImportTransactionProcessors::TransactionsMatcher)
          .to receive(:call).with(import, import_transactions)
        expect(TransactionImports::ImportTransactionProcessors::DefaultActionSetter)
          .to receive(:call).with(import, import_transactions)
        expect(TransactionImports::ImportTransactionProcessors::ImportNamesProcessor)
          .to receive(:call).with(import, import_transactions)

        run_pipeline
      end
    end

    context 'when save is false' do
      let(:save) { false }

      it 'runs the pipeline and do not save the import transactions' do
        expect(import_transactions[0]).not_to receive(:save)

        expect(TransactionImports::ImportTransactionProcessors::TransactionsMatcher)
          .to receive(:call).with(import, import_transactions)
        expect(TransactionImports::ImportTransactionProcessors::DefaultActionSetter)
          .to receive(:call).with(import, import_transactions)
        expect(TransactionImports::ImportTransactionProcessors::ImportNamesProcessor)
          .to receive(:call).with(import, import_transactions)

        run_pipeline
      end
    end
  end
end
