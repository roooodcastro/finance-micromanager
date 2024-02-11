# frozen_string_literal: true

RSpec.describe TransactionPredictionsController do
  let(:user) { create(:user) }
  let(:profile) { create(:profile, user:) }

  before do
    sign_in user
    session[:current_profile_id] = profile.id
  end

  describe 'GET index' do
    subject(:index_request) { get :index, format: }

    let!(:transaction_prediction_a) { create(:transaction_prediction, profile:) }
    let!(:transaction_prediction_b) { create(:transaction_prediction, profile:) }

    let(:expected_props) do
      {
        'transactionPredictions' => array_including(
          CamelizeProps.call(transaction_prediction_a.as_json),
          CamelizeProps.call(transaction_prediction_b.as_json)
        )
      }
    end

    before { index_request }

    context 'when the format is HTML', :inertia do
      let(:format) { :html }

      it 'renders the index component' do
        expect_inertia.to render_component('transaction_predictions/Index')
        expect(inertia.props.deep_stringify_keys).to include(expected_props)
      end
    end

    context 'when the format is JSON' do
      let(:format) { :json }

      it 'renders the transaction_predictions as json' do
        expect(json_response).to match(expected_props)
      end
    end
  end

  describe 'GET show' do
    subject(:show_request) { get :show, format: format, params: { id: transaction_prediction.id } }

    let!(:transaction_prediction) { create(:transaction_prediction, profile:) }

    let(:expected_props) { { 'transactionPrediction' => CamelizeProps.call(transaction_prediction.as_json) } }

    before { show_request }

    context 'when the format is HTML', :inertia do
      let(:format) { :html }

      it 'renders the show component' do
        expect_inertia.to render_component('transaction_predictions/Show')
        expect(inertia.props.deep_stringify_keys).to include(expected_props)
      end
    end

    context 'when the format is JSON' do
      let(:format) { :json }

      it 'renders the transaction_prediction as json' do
        expect(json_response).to match(expected_props)
      end
    end
  end

  describe 'GET new', :inertia do
    subject(:new_request) { get :new }

    before { new_request }

    it 'renders the new component' do
      expect_inertia.to render_component('transaction_predictions/New')
    end
  end

  describe 'GET edit', :inertia do
    subject(:edit_request) { get :edit, params: { id: transaction_prediction.id } }

    let!(:transaction_prediction) { create(:transaction_prediction, profile:) }
    let(:expected_props) { { 'transactionPrediction' => CamelizeProps.call(transaction_prediction.as_json) } }

    before { edit_request }

    it 'renders the edit component' do
      expect_inertia.to render_component('transaction_predictions/Edit')
      expect(inertia.props.deep_stringify_keys).to include(expected_props)
    end
  end

  describe 'POST create' do
    subject(:create_request) { post :create, params: { transaction_prediction: params } }

    let(:category) { create(:category, profile:) }

    context 'when parameters are present and valid for a regular prediction' do
      let(:params) do
        {
          name:       'Tesco to Groceries',
          rules_json: {
            conditions: [
              {
                operator: :contains,
                column:   'name',
                value:    'Tesco'
              }
            ],
            actions:    [
              {
                column: 'category_id',
                value:  category.id
              }
            ]
          }.to_json
        }
      end

      let(:expected_flash) { 'Transaction Prediction "Tesco to Groceries" was successfully created.' }

      it 'creates a new transaction_prediction and redirects to index' do
        expect { create_request }.to change { TransactionPrediction.count }.by(1)
        expect(response).to redirect_to transaction_predictions_path
        expect(flash[:success]).to eq expected_flash
      end
    end

    context 'when the transaction_prediction cannot be created', :inertia do
      let(:params) do
        {
          name:       'Tesco to Groceries',
          rules_json: {
            conditions: [
              {
                operator: :contains,
                column:   'name',
                value:    'Tesco'
              }
            ],
            actions:    []
          }.to_json
        }
      end

      let(:expected_flash) { 'Transaction Prediction could not be created: Prediction Rules is invalid' }

      it 'does not create a new transaction prediction and renders new' do
        expect { create_request }.to not_change { TransactionPrediction.count }
        expect_inertia.to render_component('transaction_predictions/New')
        expect(flash[:error]).to eq expected_flash
      end
    end
  end

  describe 'PATCH update' do
    subject(:update_request) do
      patch :update, params: { id: transaction_prediction.id, transaction_prediction: params }
    end

    let(:transaction_prediction) { create(:transaction_prediction, profile:) }

    context 'when the params are present and valid' do
      let(:params) do
        {
          name: 'Tesco to Subscriptions'
        }
      end

      let(:expected_flash) { 'Transaction Prediction "Tesco to Subscriptions" was successfully updated.' }

      it 'updates the transaction prediction and redirects to index' do
        expect { update_request }.to change { transaction_prediction.reload.name }.to('Tesco to Subscriptions')
        expect(response).to redirect_to(transaction_predictions_path)
        expect(flash[:success]).to eq expected_flash
      end
    end

    context 'when the transaction prediction cannot be updated', :inertia do
      let(:params) { { name: nil } }

      let(:expected_flash) { 'Transaction Prediction could not be updated: Name can\'t be blank' }

      it 'does not update the transaction prediction and renders edit form' do
        expect { update_request }.to not_change { transaction_prediction.reload.name }
        expect_inertia.to render_component('transaction_predictions/Edit')
        expect(flash[:error]).to eq expected_flash
      end
    end
  end

  describe 'DELETE destroy', :travel_to_now do
    subject(:destroy_request) do
      delete :destroy, params: { id: transaction_prediction.id }
    end

    let!(:transaction_prediction) do
      create(:transaction_prediction, profile: profile, disabled_at: nil, name: 'Test')
    end

    let(:expected_json) { { 'message' => 'Transaction Prediction "Test" was successfully deleted.' } }

    it 'disables the transaction prediction and renders json' do
      expect { destroy_request }.to change { TransactionPrediction.count }.by(-1)
      expect(json_response).to eq(expected_json)
    end
  end

  describe 'DELETE disable', :travel_to_now do
    subject(:disable_request) do
      delete :disable, params: { id: transaction_prediction.id }
    end

    let!(:transaction_prediction) do
      create(:transaction_prediction, profile: profile, disabled_at: nil, name: 'Test')
    end

    let(:expected_json) { { 'message' => 'Transaction Prediction "Test" was successfully disabled.' } }

    it 'disables the transaction prediction and renders json' do
      expect { disable_request }.to change { transaction_prediction.reload.disabled_at }.to(Time.current)
      expect(json_response).to eq(expected_json)
    end
  end

  describe 'PATCH reenable', :travel_to_now do
    subject(:reenable_request) do
      patch :reenable, params: { id: transaction_prediction.id }
    end

    let!(:transaction_prediction) do
      create(:transaction_prediction, profile: profile, disabled_at: Time.current, name: 'Test')
    end

    let(:expected_json) { { 'message' => 'Transaction Prediction "Test" was successfully re-enabled.' } }

    it 'reenables the transaction prediction and renders json' do
      expect { reenable_request }.to change { transaction_prediction.reload.disabled_at }.to(nil)
      expect(json_response).to eq(expected_json)
    end
  end
end
