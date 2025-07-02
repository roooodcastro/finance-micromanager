# frozen_string_literal: true

RSpec.describe Budgets::CreateOrUpdateBudgetInstanceService, :aggregate_failures do
  describe '#self.call' do
    subject(:call) { described_class.call(budget) }

    let(:profile) { create(:profile) }
    let(:budget) { create(:budget, profile: profile, owner: profile, limit_type: :absolute, limit_amount: 10) }

    context 'when there are no current budget instances' do
      it 'creates a budget_instance for the budget and updates the budget amounts' do
        expect(Budgets::UpdateBudgetInstancesAmountsService).to receive(:call).with(profile)
        expect { call }.to change { BudgetInstance.count }.by(1)
        new_budget_instance = BudgetInstance.last
        expect(new_budget_instance.budget).to eq(budget)
      end
    end

    context 'when there is already a current budget instances' do
      let!(:budget_instance) do
        create(:budget_instance,
               budget:           budget,
               profile:          profile,
               owner:            profile,
               limit_type:       :percentage,
               limit_amount:     nil,
               limit_percentage: 20)
      end

      it 'does not create a new budget_instance, updates the existing budget_instance, and the amounts' do
        expect(Budgets::UpdateBudgetInstancesAmountsService).to receive(:call).with(profile)
        expect { call }
          .to not_change { BudgetInstance.count }
          .and change { budget_instance.reload.limit_amount.to_f }
          .to(10)
          .and change { budget_instance.limit_percentage }
          .to(nil)
          .and change { budget_instance.limit_type }
          .to('absolute')
      end
    end

    context 'when there is an error' do
      before { allow(Budgets::BudgetInstanceFactoryService).to receive(:call).and_raise(ActiveRecord::RecordInvalid) }

      it 'does not create a new budget_instance and reports the error to NewRelic' do
        expect(NewRelic::Agent).to receive(:notice_error)
        expect { call }.not_to change { BudgetInstance.count }
      end
    end
  end
end
