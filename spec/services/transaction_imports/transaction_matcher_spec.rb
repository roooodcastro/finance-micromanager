# frozen_string_literal: true

RSpec.describe TransactionImports::TransactionMatcher, type: :service do
  describe 'self.call' do
    subject(:matches) { described_class.call(import_transaction, transactions).matches }

    let(:import) { create(:import) }

    let(:import_transaction) do
      create(:import_transaction, import: import, name: 'Supermarket', amount: 5.00, transaction_date: '2024-06-22')
    end

    context 'when there are no matches' do
      let(:transactions) { [] }

      it { is_expected.to be_empty }
    end

    context 'when a transaction matches because all main attributes are the same' do
      let(:transactions) { [matched_transaction] }
      let!(:matched_transaction) do
        create(:transaction, name: 'Supermarket', amount: 5, transaction_date: '2024-06-22')
      end

      it { is_expected.to eq([{ transaction: matched_transaction, match_score: 3, already_imported: false }]) }
    end

    context 'when a transaction matches because their name and amount are the same' do
      let(:transactions) { [matched_transaction] }
      let!(:matched_transaction) { create(:transaction, name: 'Supermarket', amount: 5) }

      it { is_expected.to eq([{ transaction: matched_transaction, match_score: 2, already_imported: false }]) }
    end

    context 'when a transaction matches because their date and amount are the same' do
      let(:transactions) { [matched_transaction] }
      let!(:matched_transaction) { create(:transaction, transaction_date: '2024-06-22', amount: 5) }

      it { is_expected.to eq([{ transaction: matched_transaction, match_score: 2, already_imported: false }]) }
    end

    context 'when a transaction matches because their name is the same and amount is close enough' do
      let(:transactions) { [matched_transaction] }
      let!(:matched_transaction) { create(:transaction, name: 'Supermarket', amount: 4.95) }

      it { is_expected.to eq([{ transaction: matched_transaction, match_score: 1.5, already_imported: false }]) }
    end

    context 'when a transaction matches because their name is the same and date is close enough' do
      let(:transactions) { [matched_transaction] }
      let!(:matched_transaction) { create(:transaction, name: 'Supermarket', transaction_date: '2024-06-20') }

      it { is_expected.to eq([{ transaction: matched_transaction, match_score: 1.5, already_imported: false }]) }
    end

    context 'when a transaction does not match because the match score is too low' do
      let(:transactions) { [matched_transaction] }
      let!(:matched_transaction) { create(:transaction, name: 'Supermarket') }

      it { is_expected.to eq([]) }
    end

    context 'when more than one transaction matches with different match scores' do
      let(:transactions) { [low_matched_transaction, high_matched_transaction] }
      let!(:low_matched_transaction) { create(:transaction, name: 'Supermarket', transaction_date: '2024-06-21') }
      let!(:high_matched_transaction) { create(:transaction, name: 'Supermarket', transaction_date: '2024-06-22') }

      it 'returns the matches in the reverse score order' do
        expect(matches).to eq([
                                { transaction: high_matched_transaction, match_score: 2, already_imported: false },
                                { transaction: low_matched_transaction, match_score: 1.5, already_imported: false }
                              ])
      end
    end

    context 'when a transaction matches with a transaction from another import' do
      let(:transactions) { [matched_transaction] }
      let(:other_import) { create(:import) }
      let!(:matched_transaction) do
        create(:transaction, name: 'Supermarket', transaction_date: '2024-06-20', import: other_import)
      end

      it { is_expected.to eq([{ transaction: matched_transaction, match_score: 1.5, already_imported: true }]) }
    end
  end
end
