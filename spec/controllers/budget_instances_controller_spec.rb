# frozen_string_literal: true

RSpec.describe BudgetInstancesController do
  let(:user) { create(:user) }
  let(:profile) { create(:profile, user:) }

  before do
    sign_in user
    session[:current_profile_id] = profile.id
  end

  describe 'GET index' do
    subject(:index_request) { get :index, format:, params: }

    let(:params) { {} }
    let!(:category) { create(:category, profile:) }
    let!(:budget_instance) { create(:budget_instance, profile: profile, owner: category) }

    context 'for a JSON request' do
      let(:format) { :json }
      let(:params) do
        {
          owner_type: budget_instance.owner_type,
          owner_id:   budget_instance.owner_id,
          start_date: budget_instance.start_date.iso8601,
          end_date:   budget_instance.end_date.iso8601
        }
      end

      it 'renders the budgets instances as json' do
        allow(BudgetInstanceSearch).to receive(:new).and_call_original
        expect(BudgetInstanceSearch).to receive(:new).with(anything, params).and_call_original

        index_request

        expect(json_response).to eq('budgetInstances' => [CamelizeProps.call(budget_instance.as_json)])
      end
    end
  end
end
