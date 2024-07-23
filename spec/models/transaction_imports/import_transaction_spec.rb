# frozen_string_literal: true

RSpec.describe TransactionImports::ImportTransaction do
  describe '#new' do
    subject(:import_transaction) { described_class.new(transaction_attributes) }

    let(:transaction_attributes) do
      {
        original_import_name: 'abc',
        transaction_date:     '2024-07-23',
        import_file_index:    42,
        amount:               4.99
      }
    end

    it 'sets the id and default action_id' do
      expect(import_transaction.id).to eq('1cfde17a-2cdc-5d50-b3e7-8ed01000b408')
      expect(import_transaction.action_id).to eq(:import)
    end
  end

  describe '#find_matches' do
    subject(:matches) do
      import_transaction.find_matches(transactions)
      import_transaction.matches
    end

    let(:import_transaction) do
      described_class.new(name: 'Supermarket', amount: 5.00, transaction_date: '2024-06-22', import_file_index: 2)
    end

    context 'when there are no matches' do
      let(:transactions) { [] }

      it { is_expected.to be_empty }
    end

    context 'when a transaction matches exactly by their id' do
      let(:transactions) { [matched_transaction] }
      let!(:matched_transaction) { create(:transaction, import_preview_id: '2d18aa73-95d6-534b-b17e-75671145c2b6') }

      it { is_expected.to eq([{ transaction: matched_transaction, match_score: described_class::EXACT_MATCH_SCORE }]) }
    end

    context 'when a transaction matches because all main attributes are the same' do
      let(:transactions) { [matched_transaction] }
      let!(:matched_transaction) do
        create(:transaction, name: 'Supermarket', amount: 5, transaction_date: '2024-06-22')
      end

      it { is_expected.to eq([{ transaction: matched_transaction, match_score: 3 }]) }
    end

    context 'when a transaction matches because their name and amount are the same' do
      let(:transactions) { [matched_transaction] }
      let!(:matched_transaction) { create(:transaction, name: 'Supermarket', amount: 5) }

      it { is_expected.to eq([{ transaction: matched_transaction, match_score: 2 }]) }
    end

    context 'when a transaction matches because their date and amount are the same' do
      let(:transactions) { [matched_transaction] }
      let!(:matched_transaction) { create(:transaction, transaction_date: '2024-06-22', amount: 5) }

      it { is_expected.to eq([{ transaction: matched_transaction, match_score: 2 }]) }
    end

    context 'when a transaction matches because their name is the same and amount is close enough' do
      let(:transactions) { [matched_transaction] }
      let!(:matched_transaction) { create(:transaction, name: 'Supermarket', amount: 4.95) }

      it { is_expected.to eq([{ transaction: matched_transaction, match_score: 1.5 }]) }
    end

    context 'when a transaction matches because their name is the same and date is close enough' do
      let(:transactions) { [matched_transaction] }
      let!(:matched_transaction) { create(:transaction, name: 'Supermarket', transaction_date: '2024-06-20') }

      it { is_expected.to eq([{ transaction: matched_transaction, match_score: 1.5 }]) }
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
                                { transaction: high_matched_transaction, match_score: 2 },
                                { transaction: low_matched_transaction, match_score: 1.5 }
                              ])
      end
    end
  end
end
