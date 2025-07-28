# frozen_string_literal: true

RSpec.describe BudgetsController, :travel_to_now do
  let(:user) { create(:user) }
  let(:profile) { create(:profile, user:) }

  before do
    sign_in user
    session[:current_profile_id] = profile.id
  end

  describe 'GET index' do
    subject(:index_request) { get :index, format: }

    let!(:category) { create(:category, profile:) }
    let!(:budget) { create(:budget, profile: profile, owner: category) }
    let!(:profile_budget) { create(:budget, profile: profile, owner: profile) }

    context 'for a HTML request', :inertia do
      let(:format) { :html }

      it 'renders the index component' do
        index_request

        expect_inertia.to render_component('budgets/Index')
      end
    end

    context 'for a JSON request' do
      let(:format) { :json }

      it 'renders the budgets as json' do
        index_request

        expect(json_response).to eq(
          'budgets'       => [CamelizeProps.call(budget.as_json), CamelizeProps.call(profile_budget.as_json)],
          'profileBudget' => CamelizeProps.call(profile_budget.as_json)
        )
      end
    end
  end

  describe 'GET show', :inertia do
    subject(:show_request) { get :show, format: format, params: { id: budget.id } }

    let!(:budget) { create(:budget, profile:) }

    context 'for a HTML request', :inertia do
      let(:format) { :html }
      let(:expected_props) { CamelizeProps.call(budget: budget.as_json) }

      it 'renders the show component' do
        show_request

        expect_inertia.to render_component('budgets/Show').and include_props(expected_props)
      end
    end

    context 'for a JSON request' do
      let(:format) { :json }
      let(:expected_json) { CamelizeProps.call('budget' => budget.as_json) }

      it 'renders the budget as json' do
        show_request

        expect(json_response).to eq(expected_json)
      end
    end
  end

  describe 'POST create' do
    subject(:create_request) { post :create, params: }

    let(:category) { create(:category, profile:) }

    context 'when params are valid for a category budget' do
      let(:params) do
        {
          budget: {
            limit_type:       'percentage',
            limit_percentage: 10,
            owner_type:       'Category',
            owner_id:         category.id
          }
        }
      end

      it 'creates the new budget and budget_instance for current period' do
        expect(Budgets::CreateOrUpdateBudgetInstanceService).to receive(:call).and_call_original

        expect { create_request }
          .to change { Budget.count }
          .by(1)
          .and change { BudgetInstance.count }
          .by(1)

        expect(json_response).to eq({ 'message' => 'Budget was successfully set.' })
        new_budget          = Budget.last
        expect(new_budget.owner).to eq(category)
        expect(new_budget.formatted_limit).to eq('10.0%')
        new_budget_instance = BudgetInstance.last
        expect(new_budget_instance.budget).to eq(new_budget)
      end
    end

    context 'when params are invalid for a category budget' do
      let(:params) do
        {
          budget: {
            limit_type:   'percentage',
            limit_amount: 5,
            owner_type:   'Category',
            owner_id:     category.id
          }
        }
      end

      it 'does not create a new budget' do
        expect(Budgets::CreateOrUpdateBudgetInstanceService).not_to receive(:call)

        expect { create_request }.not_to change { Budget.count }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response).to eq(
          { 'message' => 'Budget could not be set: Limit must be blank, Limit percentage can\'t be blank, ' \
                         'Limit percentage must be a value between 0 and 100' }
        )
      end
    end

    context 'when params are valid for a profile budget' do
      let(:params) do
        {
          budget: {
            limit_type:       'percentage',
            limit_percentage: 10,
            owner_type:       'Profile',
            owner_id:         profile.id
          }
        }
      end

      it 'creates the new budget' do
        expect(Budgets::CreateOrUpdateBudgetInstanceService).to receive(:call).and_call_original
        expect { create_request }.to change { Budget.count }.by(1)

        expect(json_response).to eq({ 'message' => 'Budget was successfully set.' })
        new_budget = Budget.last
        expect(new_budget.owner).to eq(profile)
        expect(new_budget.formatted_limit).to eq('10.0%')
      end
    end

    context 'when params are invalid for a profile budget' do
      let(:params) do
        {
          budget: {
            limit_type:   'percentage',
            limit_amount: 5,
            owner_type:   'Profile',
            owner_id:     profile.id
          }
        }
      end

      it 'does not create a new budget' do
        expect(Budgets::CreateOrUpdateBudgetInstanceService).not_to receive(:call)
        expect { create_request }.not_to change { Budget.count }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response).to eq(
          { 'message' => 'Budget could not be set: Limit must be blank, Limit percentage can\'t be blank, ' \
                         'Limit percentage must be a value between 0 and 100' }
        )
      end
    end
  end

  describe 'PATCH update' do
    subject(:update_request) { patch :update, params: }

    let!(:budget) { create(:budget, :absolute, profile: profile, owner: profile, limit_amount: 10) }
    let!(:budget_instance) { create(:budget_instance, :from_budget, budget:, profile:) }

    context 'when params are valid' do
      let(:params) { { id: budget.id, budget: { limit_amount: 15, carryover: true } } }

      it 'updates the budget and the budget instance for the current period' do
        expect(Budgets::CreateOrUpdateBudgetInstanceService).to receive(:call).with(budget).and_call_original
        expect { update_request }
          .to not_change { Budget.count }
          .and change { budget_instance.reload.limit_amount.to_f }
          .to(15)

        expect(json_response).to eq({ 'message' => 'Budget was successfully updated.' })
        expect(budget.reload.limit_amount.to_f).to eq(15)
        expect(budget.carryover).to be(true)
      end
    end

    context 'when params are invalid' do
      let(:params) { { id: budget.id, budget: { limit_percentage: 10 } } }

      it 'does not update the budget' do
        expect(Budgets::CreateOrUpdateBudgetInstanceService).not_to receive(:call)
        expect { update_request }.not_to change { Budget.count }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response).to eq({ 'message' => 'Budget could not be updated: Limit percentage must be blank' })
      end
    end
  end

  describe 'DELETE destroy' do
    subject(:delete_request) { delete :destroy, params: { id: budget.id } }

    let!(:budget) { create(:budget, profile: profile, owner: profile) }

    before { create(:budget_instance, :from_budget, budget:) }

    context 'when the budget can be disabled' do
      it 'disables the budget and renders json' do
        expect(Budgets::DestroyBudgetInstanceService).to receive(:call).with(budget).and_call_original
        expect { delete_request }
          .to not_change { Budget.count }
          .and change { budget.reload.disabled? }
          .to(true)
          .and change { BudgetInstance.count }
          .by(-1)

        expect(budget.current_budget_instance).to be_nil
        expect(json_response).to eq('message' => 'Budget was successfully disabled.')
      end
    end

    context 'when an error happens' do
      before { allow_any_instance_of(Budget).to receive(:disable!).and_raise(ActiveRecord::RecordInvalid) }

      it 'does not disables the budget' do
        expect(Budgets::DestroyBudgetInstanceService).not_to receive(:call)
        expect { delete_request }
          .to not_change { Budget.count }
          .and not_change { budget.reload.disabled? }

        expect(json_response).to eq('message' => 'Budget could not be disabled.')
      end
    end
  end

  describe 'PATCH reenable' do
    subject(:reenable_request) { patch :reenable, params: { id: budget.id } }

    let!(:budget) { create(:budget, :disabled, profile: profile, owner: profile) }

    context 'when the budget can be re-enabled' do
      it 're-enables the budget and renders json' do
        expect(Budgets::CreateOrUpdateBudgetInstanceService).to receive(:call).with(budget).and_call_original
        expect { reenable_request }
          .to not_change { Budget.count }
          .and change { budget.reload.disabled? }
          .to(false)
          .and change { BudgetInstance.count }
          .by(1)

        new_budget_instance = BudgetInstance.last
        expect(new_budget_instance.budget).to eq(budget)

        expect(json_response).to eq('message' => 'Budget was successfully re-enabled.')
      end
    end

    context 'when an error happens' do
      before { allow_any_instance_of(Budget).to receive(:enable!).and_raise(ActiveRecord::RecordInvalid) }

      it 'does not reenables the budget' do
        expect(Budgets::CreateOrUpdateBudgetInstanceService).not_to receive(:call)
        expect { reenable_request }
          .to not_change { Budget.count }
          .and not_change { budget.reload.disabled? }

        expect(json_response).to eq('message' => 'Budget could not be re-enabled.')
      end
    end
  end
end
