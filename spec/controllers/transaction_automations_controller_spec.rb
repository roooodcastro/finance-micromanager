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
        get :index, format: :json

        expect(json_response).to match(expected_props)
      end
    end
  end
end
