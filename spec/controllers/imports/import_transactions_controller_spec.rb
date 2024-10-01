# frozen_string_literal: true

RSpec.describe Imports::ImportTransactionsController do
  let(:user) { create(:user) }
  let(:profile) { create(:profile, user:) }

  before do
    sign_in user
    allow(Current).to receive_messages(user:, profile:)
  end

  describe 'GET index', :aggregate_failures do
    subject(:index_request) { get :index, params: { import_id: import.id } }

    let(:import) { create(:import, :in_progress, profile:) }

    let!(:import_transaction1) { create(:import_transaction, import:).tap { |it| it.matches = [] } }
    let!(:import_transaction2) { create(:import_transaction, import:).tap { |it| it.matches = [] } }

    before { create(:import_transaction, import: create(:import)) }

    it 'returns the import_transactions of that import' do
      index_request

      expect(json_response).to match(
        CamelizeProps.call(import_transactions: [import_transaction1, import_transaction2].as_json)
      )
    end
  end

  describe 'PATCH update', :aggregate_failures do
    subject(:update_request) { patch :update, params: }

    let(:import) { create(:import, profile:) }
    let!(:import_transaction) { create(:import_transaction, import: import, name: 'Test') }

    context 'when params are valid' do
      let(:params) do
        {
          id:                 import_transaction.id,
          import_id:          import.id,
          import_transaction: { name: 'New Name', category_id: subcategory.compose_category_id }
        }
      end

      let(:expected_json) { hash_including('message' => 'Saved') }
      let(:category) { create(:category, profile:) }
      let(:subcategory) { create(:subcategory, category:) }

      it 'updates the transaction' do
        expect { update_request }
          .to not_change { TransactionImports::ImportTransaction.count }
          .and change { import_transaction.reload.name }
          .to('New Name')
          .and change { import_transaction.reload.category }
          .to(category)
          .and change { import_transaction.reload.subcategory }
          .to(subcategory)

        expect(response).to have_http_status(:ok)
        expect(json_response).to match(expected_json)
      end
    end

    context 'when passing a system category' do
      let(:params) do
        {
          id:                 import_transaction.id,
          import_id:          import.id,
          import_transaction: { name: 'New Name', category_id: category.id }
        }
      end

      let(:expected_json) { hash_including('message' => 'Saved') }
      let(:category) { create(:category, :system, profile:) }

      it 'updates the transaction' do
        expect { update_request }
          .to not_change { TransactionImports::ImportTransaction.count }
          .and change { import_transaction.reload.name }
          .to('New Name')
          .and not_change { import_transaction.reload.category }

        expect(response).to have_http_status(:ok)
        expect(json_response).to match(expected_json)
      end
    end

    context 'when params are invalid' do
      let(:params) { { id: import_transaction.id, import_id: import.id, import_transaction: { name: nil } } }

      let(:expected_json) { { 'message' => "Preview transaction could not be updated: Name can't be blank" } }

      it 'does not update the transaction' do
        expect { update_request }
          .to not_change { TransactionImports::ImportTransaction.count }
          .and not_change { import_transaction.reload.name }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response).to eq(expected_json)
      end
    end
  end
end
