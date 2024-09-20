# frozen_string_literal: true

RSpec.describe TransactionsController do
  let(:user) { create(:user) }
  let(:profile) { create(:profile, user:) }

  before do
    sign_in user
    allow(Current).to receive_messages(user:, profile:)
  end

  describe 'GET index', :inertia do
    let!(:transaction_a) { create(:transaction, profile: profile, transaction_date: 1.day.ago, created_by: user) }
    let!(:transaction_b) { create(:transaction, profile: profile, created_by: user) }

    context 'when include_statistics is false' do
      let(:expected_props) { { transactions: [transaction_b, transaction_a].as_json } }

      it 'renders the index component, returning all transactions' do
        get :index

        expect_inertia.to render_component('transactions/Index').and include_camelized_props(expected_props)
      end
    end

    context 'when include_statistics is true' do
      let(:expected_props) do
        {
          transactions: [transaction_b, transaction_a].as_json,
          statistics:   hash_including(
            spends:      0,
            moneyIn:     20,
            dailyTotals: [
              { date: 2.days.ago.to_date, spends: 0, income: 0 },
              { date: 1.day.ago.to_date, spends: 0, income: 10 },
              { date: Date.current, spends: 0, income: 10 }
            ]
          )
        }
      end

      before { allow(CurrentDateRange).to receive_messages(start_date: 2.days.ago, end_date: Date.current) }

      it 'renders the index component, returning all transactions and statistics' do
        get :index, params: { include_statistics: true }

        expect_inertia.to render_component('transactions/Index').and include_camelized_props(expected_props)
      end
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
            category_id:      "#{category.id}|#{subcategory.id}",
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
        .to eq('transactionId' => transaction.id, 'message' => 'Transaction was successfully deleted.')
    end
  end

  describe 'PATCH update_all' do
    subject(:update_all_request) { patch :update_all, params: }

    let!(:transaction_a) { create(:transaction, profile: profile, category: category_a, wallet: nil) }
    let!(:transaction_b) { create(:transaction, profile: profile, category: category_b, wallet: wallet_a) }
    let!(:transaction_c) do
      create(:transaction, profile: profile, category: category_a, subcategory: subcategory, wallet: nil)
    end

    let(:category_a) { create(:category) }
    let(:category_b) { create(:category) }
    let(:subcategory) { create(:subcategory, category: category_a) }
    let(:wallet_a) { create(:wallet, profile:) }
    let(:wallet_b) { create(:wallet, profile:) }

    context 'when category_id is specified with no subcategory' do
      let(:params) do
        { transaction_ids: transaction_ids, transaction: { name: 'New Name', category_id: category_b.id } }
      end

      let(:transaction_ids) { [transaction_a.id, transaction_c.id] }

      let(:expected_json) { { 'message' => 'Transactions were successfully updated.' } }

      it 'updates only the category of all transactions' do
        expect { update_all_request }
          .to not_change { Transaction.count }
          .and change { transaction_a.reload.category }
          .to(category_b)
          .and not_change { transaction_a.wallet }
          .and not_change { transaction_a.name }
          .and change { transaction_c.reload.category }
          .to(category_b)
          .and change { transaction_c.subcategory }
          .to(nil)
          .and not_change { transaction_b.reload.category }

        expect(response).to have_http_status(:ok)
        expect(json_response).to eq(expected_json)
      end
    end

    context 'when category_id and subcategory_id are specified' do
      let(:params) do
        {
          transaction_ids: transaction_ids,
          transaction:     { name: 'New Name', category_id: subcategory.compose_category_id }
        }
      end

      let(:transaction_ids) { [transaction_a.id, transaction_b.id] }

      let(:expected_json) { { 'message' => 'Transactions were successfully updated.' } }

      it 'updates only the category and subcategory of all transactions' do
        expect { update_all_request }
          .to not_change { Transaction.count }
          .and not_change { transaction_a.reload.category }
          .and change { transaction_a.subcategory }
          .to(subcategory)
          .and not_change { transaction_a.wallet }
          .and not_change { transaction_a.name }
          .and change { transaction_b.reload.category }
          .to(category_a)
          .and change { transaction_b.subcategory }
          .to(subcategory)
          .and not_change { transaction_c.reload.category }

        expect(response).to have_http_status(:ok)
        expect(json_response).to eq(expected_json)
      end
    end

    context 'when wallet_id is specified' do
      let(:params) do
        { transaction_ids: transaction_ids, transaction: { name: 'New Name', wallet_id: wallet_b.id } }
      end

      let(:transaction_ids) { [transaction_b.id, transaction_c.id] }

      let(:expected_json) { { 'message' => 'Transactions were successfully updated.' } }

      it 'updates only the wallet of all transactions' do
        expect { update_all_request }
          .to not_change { Transaction.count }
          .and not_change { transaction_b.reload.category }
          .and not_change { transaction_b.subcategory }
          .and change { transaction_b.wallet }
          .to(wallet_b)
          .and not_change { transaction_b.name }
          .and not_change { transaction_c.reload.category }
          .and not_change { transaction_c.subcategory }
          .and change { transaction_c.wallet }
          .to(wallet_b)
          .and not_change { transaction_a.reload.wallet }

        expect(response).to have_http_status(:ok)
        expect(json_response).to eq(expected_json)
      end
    end

    context 'when there is an error' do
      let(:params) { { transaction_ids: transaction_ids, transaction: { category_id: 'invalid' } } }
      let(:transaction_ids) { [transaction_a.id, transaction_b.id, transaction_c.id] }

      let(:expected_json) do
        { 'message' => 'Transactions could not be updated: Validation failed: Category must exist' }
      end

      it 'does not update anything' do
        expect { update_all_request }
          .to not_change { Transaction.count }
          .and not_change { transaction_a.reload.attributes }
          .and not_change { transaction_b.reload.attributes }
          .and not_change { transaction_c.reload.attributes }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response).to eq(expected_json)
      end
    end
  end
end
