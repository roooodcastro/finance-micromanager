# frozen_string_literal: true

RSpec.describe TransactionAutomationsController do
  let(:user) { create(:user) }
  let(:profile) { create(:profile, user:) }

  before do
    sign_in user
    session[:current_profile_id] = profile.id
  end

  describe 'GET index' do
    subject(:index_request) { get :index, format: }

    let!(:transaction_automation_a) { create(:transaction_automation, profile:) }
    let!(:transaction_automation_b) { create(:transaction_automation, profile:) }

    let(:expected_props) do
      {
        'transactionAutomations' => array_including(
          CamelizeProps.call(transaction_automation_a.as_json),
          CamelizeProps.call(transaction_automation_b.as_json)
        )
      }
    end

    before { index_request }

    context 'when the format is HTML', :inertia do
      let(:format) { :html }

      it 'renders the index component' do
        expect_inertia.to render_component('transaction_automations/Index')
        expect(inertia.props.deep_stringify_keys).to include(expected_props)
      end
    end

    context 'when the format is JSON' do
      let(:format) { :json }

      it 'renders the transaction_automations as json' do
        expect(json_response).to match(expected_props)
      end
    end
  end

  describe 'GET show' do
    subject(:show_request) { get :show, format: format, params: { id: transaction_automation.id } }

    let!(:transaction_automation) { create(:transaction_automation, profile:) }

    let(:expected_props) { { 'transactionAutomation' => CamelizeProps.call(transaction_automation.as_json) } }

    before { show_request }

    context 'when the format is HTML', :inertia do
      let(:format) { :html }

      it 'renders the index component' do
        expect_inertia.to render_component('transaction_automations/Show')
        expect(inertia.props.deep_stringify_keys).to include(expected_props)
      end
    end

    context 'when the format is JSON' do
      let(:format) { :json }

      it 'renders the transaction_automation as json' do
        expect(json_response).to match(expected_props)
      end
    end
  end

  describe 'POST create' do
    subject(:create_request) { post :create, params: { transaction_automation: params } }

    let(:category) { create(:category, profile:) }
    let(:subcategory) { create(:subcategory, category:) }
    let(:wallet) { create(:wallet, profile:) }

    context 'when parameters are present and valid' do
      let(:params) do
        {
          schedule_type:           'W',
          schedule_interval:       '2',
          next_schedule_date:      2.days.from_now.to_date,
          transaction_name:        'Netflix',
          transaction_category_id: [category.id, subcategory.id].join('|'),
          transaction_wallet_id:   wallet.id,
          transaction_amount:      '-9.99'
        }
      end

      let(:expected_json) { { 'message' => 'Transaction Automation was successfully created.' } }

      it 'creates a new transaction_automation and renders json' do
        expect { create_request }.to change { TransactionAutomation.count }.by(1)
        expect(json_response).to eq(CamelizeProps.call(expected_json))
      end
    end

    context 'when the transaction_automation cannot be created' do
      let(:params) do
        {
          schedule_type:           'W',
          schedule_interval:       '2',
          next_schedule_date:      2.days.from_now.to_date,
          transaction_name:        'Netflix',
          transaction_category_id: nil,
          transaction_amount:      '-9.99'
        }
      end

      let(:expected_json) do
        { 'message' => 'Transaction Automation could not be created: Category must exist' }
      end

      it 'does not create a new transaction automation and renders json error' do
        expect { create_request }.to not_change { TransactionAutomation.count }
        expect(json_response).to eq(expected_json)
      end
    end
  end

  describe 'PATCH update' do
    subject(:update_request) do
      patch :update, params: { id: transaction_automation.id, transaction_automation: params }
    end

    let(:transaction_automation) { create(:transaction_automation, profile:) }

    context 'when the date is present and valid' do
      let(:params) { { schedule_interval: 30 } }

      let(:expected_json) { { 'message' => 'Transaction Automation was successfully updated.' } }

      it 'updates the transaction automation and renders json' do
        expect { update_request }.to change { transaction_automation.reload.schedule_interval }.to(30)
        expect(json_response).to eq(expected_json)
      end
    end

    context 'when the transaction automation cannot be updated' do
      let(:params) { { transaction_name: nil } }

      let(:expected_json) do
        { 'message' => 'Transaction Automation could not be updated: Transaction Name can\'t be blank' }
      end

      it 'does not update the transaction automation and renders json error' do
        expect { update_request }.to not_change { transaction_automation.reload.transaction_name }
        expect(json_response).to eq(expected_json)
      end
    end
  end
end
