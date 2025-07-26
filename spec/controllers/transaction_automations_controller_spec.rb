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

    context 'when parameters are present and valid for a regular automation' do
      let(:params) do
        {
          schedule_type:             'W',
          schedule_interval:         '2',
          scheduled_date:            2.days.from_now.to_date,
          transaction_name:          'Netflix',
          transaction_category_id:   subcategory.compose_category_id,
          transaction_wallet_id:     wallet.id,
          transaction_amount:        '-9.99',
          create_at_start_of_period: true,
          schedule_day:              3
        }
      end

      let(:expected_json) { { 'message' => 'Transaction Automation was successfully created.' } }

      it 'creates a new transaction_automation and renders json' do
        expect { create_request }.to change { TransactionAutomation.count }.by(1)
        expect(json_response).to eq(CamelizeProps.call(expected_json))
      end
    end

    context 'when parameters are present and valid for a custom rule automation' do
      let(:params) do
        {
          schedule_type:           'C',
          schedule_custom_rule:    'last_day_of_month',
          scheduled_date:          Date.current.end_of_month,
          transaction_name:        'Netflix',
          transaction_category_id: subcategory.compose_category_id,
          transaction_wallet_id:   wallet.id,
          transaction_amount:      '-9.99',
          schedule_day:            nil
        }
      end

      let(:expected_json) { { 'message' => 'Transaction Automation was successfully created.' } }

      it 'creates a new transaction_automation and renders json' do
        expect { create_request }.to change { TransactionAutomation.count }.by(1)
        expect(json_response).to eq(CamelizeProps.call(expected_json))
      end
    end

    context 'when the transaction_automation cannot be created' do
      let(:system_category) { create(:category, :system, profile:) }

      let(:params) do
        {
          schedule_type:           'W',
          schedule_interval:       '2',
          scheduled_date:          2.days.from_now.to_date,
          transaction_name:        'Netflix',
          transaction_category_id: system_category.id,
          transaction_amount:      '-9.99',
          schedule_day:            3
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
      let(:params) { { transaction_category_id: nil } }

      let(:expected_json) do
        { 'message' => 'Transaction Automation could not be updated: Category must exist' }
      end

      it 'does not update the transaction automation and renders json error' do
        expect { update_request }.to not_change { transaction_automation.reload.transaction_name }
        expect(json_response).to eq(expected_json)
      end
    end
  end

  describe 'DELETE destroy', :travel_to_now do
    subject(:destroy_request) do
      delete :destroy, params: { id: transaction_automation.id }
    end

    let!(:transaction_automation) { create(:transaction_automation, profile: profile, disabled_at: nil) }
    let(:expected_json) { { 'message' => 'Transaction Automation was successfully deleted.' } }

    it 'disables the transaction automation and renders json' do
      expect { destroy_request }.to change { TransactionAutomation.count }.by(-1)
      expect(json_response).to eq(expected_json)
    end
  end

  describe 'DELETE disable', :travel_to_now do
    subject(:disable_request) do
      delete :disable, params: { id: transaction_automation.id }
    end

    let(:transaction_automation) { create(:transaction_automation, profile: profile, disabled_at: nil) }
    let(:expected_json) { { 'message' => 'Transaction Automation was successfully disabled.' } }

    it 'disables the transaction automation and renders json' do
      expect { disable_request }.to change { transaction_automation.reload.disabled_at }.to(Time.current)
      expect(json_response).to eq(expected_json)
    end
  end

  describe 'PATCH reenable', :travel_to_now do
    subject(:reenable_request) do
      patch :reenable, params: { id: transaction_automation.id }
    end

    let(:transaction_automation) { create(:transaction_automation, profile: profile, disabled_at: Time.current) }
    let(:expected_json) { { 'message' => 'Transaction Automation was successfully re-enabled.' } }

    it 'reenables the transaction automation and renders json' do
      expect { reenable_request }.to change { transaction_automation.reload.disabled_at }.to(nil)
      expect(json_response).to eq(expected_json)
    end
  end
end
