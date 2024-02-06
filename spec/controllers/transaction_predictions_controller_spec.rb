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

  describe 'GET show', skip: 'not implemented' do
    subject(:show_request) { get :show, format: format, params: { id: transaction_prediction.id } }

    let!(:transaction_prediction) { create(:transaction_prediction, profile:) }

    let(:expected_props) { { 'transactionPrediction' => CamelizeProps.call(transaction_prediction.as_json) } }

    before { show_request }

    context 'when the format is HTML', :inertia do
      let(:format) { :html }

      it 'renders the index component' do
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

  describe 'POST create', skip: 'not implemented' do
    subject(:create_request) { post :create, params: { transaction_prediction: params } }

    let(:category) { create(:category, profile:) }
    let(:subcategory) { create(:subcategory, category:) }
    let(:wallet) { create(:wallet, profile:) }

    context 'when parameters are present and valid for a regular prediction' do
      let(:params) do
        {
          schedule_type:           'W',
          schedule_interval:       '2',
          scheduled_date:          2.days.from_now.to_date,
          transaction_name:        'Netflix',
          transaction_category_id: [category.id, subcategory.id].join('|'),
          transaction_wallet_id:   wallet.id,
          transaction_amount:      '-9.99'
        }
      end

      let(:expected_json) { { 'message' => 'Transaction Prediction was successfully created.' } }

      it 'creates a new transaction_prediction and renders json' do
        expect { create_request }.to change { TransactionPrediction.count }.by(1)
        expect(json_response).to eq(CamelizeProps.call(expected_json))
      end
    end

    context 'when parameters are present and valid for a custom rule prediction' do
      let(:params) do
        {
          schedule_type:           'C',
          schedule_custom_rule:    'last_day_of_month',
          scheduled_date:          Date.current.end_of_month,
          transaction_name:        'Netflix',
          transaction_category_id: [category.id, subcategory.id].join('|'),
          transaction_wallet_id:   wallet.id,
          transaction_amount:      '-9.99'
        }
      end

      let(:expected_json) { { 'message' => 'Transaction Prediction was successfully created.' } }

      it 'creates a new transaction_prediction and renders json' do
        expect { create_request }.to change { TransactionPrediction.count }.by(1)
        expect(json_response).to eq(CamelizeProps.call(expected_json))
      end
    end

    context 'when the transaction_prediction cannot be created' do
      let(:params) do
        {
          schedule_type:           'W',
          schedule_interval:       '2',
          scheduled_date:          2.days.from_now.to_date,
          transaction_name:        'Netflix',
          transaction_category_id: nil,
          transaction_amount:      '-9.99'
        }
      end

      let(:expected_json) do
        { 'message' => 'Transaction Prediction could not be created: Category must exist' }
      end

      it 'does not create a new transaction prediction and renders json error' do
        expect { create_request }.to not_change { TransactionPrediction.count }
        expect(json_response).to eq(expected_json)
      end
    end
  end

  describe 'PATCH update', skip: 'not implemented' do
    subject(:update_request) do
      patch :update, params: { id: transaction_prediction.id, transaction_prediction: params }
    end

    let(:transaction_prediction) { create(:transaction_prediction, profile:) }

    context 'when the date is present and valid' do
      let(:params) { { schedule_interval: 30 } }

      let(:expected_json) { { 'message' => 'Transaction Prediction was successfully updated.' } }

      it 'updates the transaction prediction and renders json' do
        expect { update_request }.to change { transaction_prediction.reload.schedule_interval }.to(30)
        expect(json_response).to eq(expected_json)
      end
    end

    context 'when the transaction prediction cannot be updated' do
      let(:params) { { transaction_name: nil } }

      let(:expected_json) do
        { 'message' => 'Transaction Prediction could not be updated: Transaction Name can\'t be blank' }
      end

      it 'does not update the transaction prediction and renders json error' do
        expect { update_request }.to not_change { transaction_prediction.reload.transaction_name }
        expect(json_response).to eq(expected_json)
      end
    end
  end

  describe 'DELETE destroy', :travel_to_now, skip: 'not implemented' do
    subject(:destroy_request) do
      delete :destroy, params: { id: transaction_prediction.id }
    end

    let!(:transaction_prediction) { create(:transaction_prediction, profile: profile, disabled_at: nil) }
    let(:expected_json) { { 'message' => 'Transaction Prediction was successfully deleted.' } }

    it 'disables the transaction prediction and renders json' do
      expect { destroy_request }.to change { TransactionPrediction.count }.by(-1)
      expect(json_response).to eq(expected_json)
    end
  end

  describe 'DELETE disable', :travel_to_now, skip: 'not implemented' do
    subject(:disable_request) do
      delete :disable, params: { id: transaction_prediction.id }
    end

    let(:transaction_prediction) { create(:transaction_prediction, profile: profile, disabled_at: nil) }
    let(:expected_json) { { 'message' => 'Transaction Prediction was successfully disabled.' } }

    it 'disables the transaction prediction and renders json' do
      expect { disable_request }.to change { transaction_prediction.reload.disabled_at }.to(Time.current)
      expect(json_response).to eq(expected_json)
    end
  end

  describe 'PATCH reenable', :travel_to_now, skip: 'not implemented' do
    subject(:reenable_request) do
      patch :reenable, params: { id: transaction_prediction.id }
    end

    let(:transaction_prediction) { create(:transaction_prediction, profile: profile, disabled_at: Time.current) }
    let(:expected_json) { { 'message' => 'Transaction Prediction was successfully re-enabled.' } }

    it 'reenables the transaction prediction and renders json' do
      expect { reenable_request }.to change { transaction_prediction.reload.disabled_at }.to(nil)
      expect(json_response).to eq(expected_json)
    end
  end
end
