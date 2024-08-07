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

    let!(:matched_transaction) do
      create(:transaction, name: 'Test 2', amount: 2, profile: profile, wallet: import.wallet)
    end

    let(:expected_preview_data) do
      [
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
          id:                   '59c7ee34-04aa-5bd6-a72c-de812bdd128f',
          original_import_name: 'Raw 1',
          name:                 'Test 1',
          transaction_date:     '2024-06-26',
          amount:               -4.99,
          wallet_id:            wallet.id,
          action_id:            :import,
          matches:              [],
          category_id:          '047cf511-256c-45ca-a0d6-e8b4d589742c'
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

    let(:transaction_prediction_rules_json) do
      {
        conditions: [
          {
            operator: :contains,
            column:   'name',
            value:    'Test 1'
          }
        ],
        actions:    [
          {
            column: 'category_id',
            value:  '047cf511-256c-45ca-a0d6-e8b4d589742c'
          },
          {
            column: 'wallet_id',
            value:  '047cf511-256c-45ca-a0d6-e8b4d589742c'
          }
        ]
      }
    end

    before do
      create(:reconciliation, :finished, profile: profile, date: '2024-06-24')
      create(:transaction_prediction, profile: profile, rules_json: transaction_prediction_rules_json.to_json)
      profile.reload
      allow(parser).to receive(:parse).and_return(parsed_transactions)
    end

    it { is_expected.to eq expected_preview_data.as_json }
  end
end
