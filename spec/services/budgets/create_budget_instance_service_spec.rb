# frozen_string_literal: true

RSpec.describe Budgets::CreateBudgetInstanceService, :aggregate_failures do
  describe '#self.call' do
    subject(:call) { described_class.call(budget) }

    let(:profile) { create(:profile) }
    let(:budget) { create(:budget, profile: profile, owner: profile) }

    context 'when there are no current budget instances' do
      it 'creates a budget_instance for the budget and updates the budget amounts' do
        expect(Budgets::UpdateProfileBudgetInstancesService).to receive(:call).with(profile)
        expect { call }.to change { BudgetInstance.count }.by(1)
        new_budget_instance = BudgetInstance.last
        expect(new_budget_instance.budget).to eq(budget)
      end
    end

    context 'when there is already a current budget instances' do
      before { create(:budget_instance, :from_budget, budget:) }

      it 'does not create a new budget_instance and does not update the budget amounts' do
        expect(Budgets::UpdateProfileBudgetInstancesService).not_to receive(:call)
        expect { call }.not_to change { BudgetInstance.count }
      end
    end

    context 'when there is an error' do
      before { allow(BudgetInstance).to receive(:build_from_budget).and_raise(ActiveRecord::RecordInvalid) }

      it 'does not create a new budget_instance and reports the error to NewRelic' do
        expect(NewRelic::Agent).to receive(:notice_error)
        expect { call }.not_to change { BudgetInstance.count }
      end
    end
  end
end
