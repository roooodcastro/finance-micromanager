# frozen_string_literal: true

RSpec.describe TransactionsController do
  let(:user) { create(:user) }
  let(:profile) { create(:profile, user:) }

  before do
    sign_in user
    allow(Current).to receive_messages(user:, profile:)
  end

  describe 'GET index', :inertia do
    let!(:transaction) { create(:transaction, profile: profile, created_by: user) }

    it 'renders the index component, returning all transactions' do
      get :index

      expect_inertia.to render_component('transactions/Index')
                    .and include_camelized_props({ transactions: [transaction].as_json })
    end
  end

  describe 'GET new', :inertia do
    it 'renders the new component' do
      get :new

      expect_inertia.to render_component('transactions/New')
                    .and include_camelized_props({ transaction: Transaction.new.as_json })
    end
  end

  describe 'GET edit', :inertia do
    let!(:transaction) { create(:transaction, profile: profile, created_by: user) }

    it 'renders the edit component' do
      get :edit, params: { id: transaction.id }

      expect_inertia.to render_component('transactions/Edit')
                    .and include_camelized_props({ transaction: transaction.as_json })
    end
  end

  describe 'POST create', :inertia do
    subject(:create_request) { post :create, params: }

    let!(:category) { create(:category, profile:) }

    context 'when params are valid' do
      let(:params) do
        {
          transaction: {
            name:             'Test',
            amount:           1.99,
            amount_type:      :debit,
            category_id:      category.id,
            transaction_date: Time.zone.today.to_s
          }
        }
      end

      let(:expected_json) { { 'message' => 'Transaction was successfully created.' } }

      it 'creates the new transaction' do
        expect { create_request }.to change { Transaction.count }.by(1)

        new_transaction = Transaction.last
        expect(new_transaction.name).to eq('Test')
        expect(new_transaction.amount.to_f).to eq(-1.99)
        expect(new_transaction.transaction_date).to eq(Time.zone.today)
        expect(new_transaction.created_by).to eq(user)
        expect(new_transaction.updated_by).to eq(user)
        expect(new_transaction.category).to eq(category)
        expect(new_transaction.profile).to eq(profile)

        expect(response).to have_http_status(:ok)
        expect(json_response).to eq(expected_json)
      end
    end

    context 'when a subcategory is selected' do
      let(:params) do
        {
          transaction: {
            name:             'Test',
            amount:           1.99,
            amount_type:      :debit,
            category_id:      "#{category.id},#{subcategory.id}",
            transaction_date: Time.zone.today.to_s
          }
        }
      end

      let(:subcategory) { create(:subcategory, category:) }
      let(:expected_json) { { 'message' => 'Transaction was successfully created.' } }

      it 'creates the new transaction' do
        expect { create_request }.to change { Transaction.count }.by(1)

        new_transaction = Transaction.last
        expect(new_transaction.category).to eq(category)
        expect(new_transaction.subcategory).to eq(subcategory)

        expect(response).to have_http_status(:ok)
        expect(json_response).to eq(expected_json)
      end
    end

    context 'when params are invalid' do
      let(:params) do
        {
          transaction: {
            name:             'Test',
            amount:           1.99,
            amount_type:      :debit,
            category_id:      category.id,
            transaction_date: nil
          }
        }
      end

      let(:expected_json) { { 'message' => "Transaction could not be created: Transaction date can't be blank" } }

      it 'does not create a new transaction' do
        expect { create_request }.not_to change { Transaction.count }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response).to eq(expected_json)
      end
    end
  end

  describe 'PATCH update', :inertia do
    subject(:update_request) { patch :update, params: }

    let!(:transaction) do
      create(:transaction, profile: profile, created_by: other_user, updated_by: other_user, name: 'Test')
    end

    let(:other_user) { create(:user) }

    context 'when params are valid' do
      let(:params) { { id: transaction.id, transaction: { name: 'New Name' } } }

      let(:expected_json) { { 'message' => 'Transaction was successfully updated.' } }

      it 'updates the transaction' do
        expect { update_request }
          .to not_change { Transaction.count }
          .and not_change { transaction.reload.created_by }
          .and change { transaction.reload.updated_by }
          .to(user)
          .and change { transaction.reload.name }
          .to('New Name')

        expect(response).to have_http_status(:ok)
        expect(json_response).to eq(expected_json)
      end
    end

    context 'when params are invalid' do
      let(:params) { { id: transaction.id, transaction: { name: nil } } }

      let(:expected_json) { { 'message' => "Transaction could not be updated: Name can't be blank" } }

      it 'does not update the transaction' do
        expect { update_request }.to not_change { Transaction.count }.and not_change { transaction.reload.name }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response).to eq(expected_json)
      end
    end
  end

  describe 'DELETE destroy' do
    subject(:delete_request) { delete :destroy, params: { id: transaction.id } }

    let!(:transaction) { create(:transaction, profile: profile, created_by: user) }

    it 'destroys the transaction and renders json' do
      expect { delete_request }.to change { Transaction.count }.by(-1)

      expect(json_response)
        .to eq('transactionId' => transaction.id, 'message' => 'Transaction was successfully destroyed.')
    end
  end
end
