# frozen_string_literal: true

RSpec.describe Budgets::DestroyBudgetInstanceService, :aggregate_failures do
  describe '#self.call' do
    subject(:call) { described_class.call(budget) }

    let(:profile) { create(:profile) }
    let(:budget) { create(:budget, profile: profile, owner: profile) }

    context 'when there are no current budget instances' do
      it 'does not do anything' do
        expect { call }.not_to change { BudgetInstance.count }
      end
    end

    context 'when there is a current budget instances' do
      before { create(:budget_instance, :from_budget, budget:) }

      it 'deletes the budget_instance' do
        expect { call }.to change { BudgetInstance.count }.by(-1)
      end
    end

    context 'when there is an error' do
      before do
        create(:budget_instance, :from_budget, budget:)
        allow(Budgets::UpdateBudgetInstancesAmountsService).to receive(:call).and_raise(ActiveRecord::RecordInvalid)
      end

      it 'reports the error to NewRelic' do
        expect(NewRelic::Agent).to receive(:notice_error)
        call
      end
    end
  end
end
