# frozen_string_literal: true

RSpec.describe TransactionImports::ImportCreator do
  describe '#call' do
    subject(:call) { described_class.call(import_params) }

    let(:profile) { create(:profile) }
    let(:wallet) { create(:wallet, profile:) }
    let(:source_file) { fixture_file_upload('n26.csv', 'text/csv') }
    let(:source) { Import.sources[:n26] }
    let(:import_params) { { source_file: source_file, source: source, wallet_id: wallet.id } }

    before do
      allow(Current).to receive(:profile).and_return(profile)
    end

    context 'when the import is successful' do
      it 'creates a new import record and parse the file' do
        expect_any_instance_of(TransactionImports::Parsers::N26).to receive(:parse!).and_call_original
        expect { call }
          .to change { Import.count }
          .by(1)
          .and change { TransactionImports::ImportTransaction.count }
          .by(5)

        expect(call).to be_an_instance_of(Import)
        expect(call.errors).to be_empty
      end
    end

    context 'when the import gets cancelled during parsing' do
      let(:source_file) { fixture_file_upload('n26_empty.csv', 'text/csv') }

      it 'creates a new import record and parse the file' do
        expect_any_instance_of(TransactionImports::Parsers::N26).to receive(:parse!).and_call_original
        expect { call }
          .to not_change { Import.count }
          .and not_change { TransactionImports::ImportTransaction.count }

        expect(call).to be_an_instance_of(Import)
        expect(call.errors).to be_present
      end
    end
  end
end
