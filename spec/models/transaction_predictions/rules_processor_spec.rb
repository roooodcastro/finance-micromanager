# frozen_string_literal: true

RSpec.describe TransactionPredictions::RulesProcessor do
  let(:profile) { create(:profile) }
  let(:rules_processor) { described_class.new(profile) }

  describe '#process_transaction' do
    subject(:process_transaction) { rules_processor.process_transaction(transaction, allowed_columns) }

    let!(:transaction) { Transaction.new(name: transaction_name) }
    let(:transaction_name) { 'MyTransaction' }
    let(:allowed_columns) { nil }

    # rubocop:disable RSpec/LetSetup
    let!(:transaction_prediction) { create(:transaction_prediction, profile: profile, rules_json: rules_json.to_json) }
    # rubocop:enable RSpec/LetSetup

    let(:rules_json) do
      {
        conditions: [
          {
            operator: :contains,
            column:   'name',
            value:    'Generic'
          },
          {
            operator: :equals,
            column:   'name',
            value:    'SpecificName'
          }
        ],
        actions:    [
          {
            column: 'category_id',
            value:  '047cf511-256c-45ca-a0d6-e8b4d589742c'
          },
          {
            column: 'wallet_id',
            value:  '59c7ee34-04aa-5bd6-a72c-de812bdd128f'
          }
        ]
      }
    end

    context 'when there are no transaction predictions in the profile' do
      let(:transaction_prediction) { nil }

      it 'does not change anything in the transaction' do
        expect { process_transaction }.not_to change { transaction.attributes }
      end
    end

    context 'when the transaction does not satisfy any of the prediction rule conditions' do
      let(:transaction_name) { 'MyTransaction' }

      it 'does not change anything in the transaction' do
        expect { process_transaction }.not_to change { transaction.attributes }
      end
    end

    context 'when the transaction satisfies the prediction rule equals condition' do
      let(:transaction_name) { 'SpEcIficNaMe' }

      it 'changes the category_id and wallet_id of the transaction' do
        expect { process_transaction }
          .to change { transaction.category_id }
          .to('047cf511-256c-45ca-a0d6-e8b4d589742c')
          .and change { transaction.wallet_id }
          .to('59c7ee34-04aa-5bd6-a72c-de812bdd128f')
      end
    end

    context 'when the transaction satisfies the prediction rule contains condition' do
      let(:transaction_name) { 'GeNeRiCNaMe' }

      it 'changes the category_id and wallet_id of the transaction' do
        expect { process_transaction }
          .to change { transaction.category_id }
          .to('047cf511-256c-45ca-a0d6-e8b4d589742c')
          .and change { transaction.wallet_id }
          .to('59c7ee34-04aa-5bd6-a72c-de812bdd128f')
      end
    end

    context 'when the transaction satisfies the conditions and allowed_columns is specified' do
      let(:transaction_name) { 'GenericName' }
      let(:allowed_columns) { ['category_id'] }

      it 'changes only the category_id of the transaction' do
        expect { process_transaction }
          .to change { transaction.category_id }
          .to('047cf511-256c-45ca-a0d6-e8b4d589742c')
          .and not_change { transaction.wallet_id }
      end
    end
  end
end
