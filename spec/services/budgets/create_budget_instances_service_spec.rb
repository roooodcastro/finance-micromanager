# frozen_string_literal: true

RSpec.describe Budgets::CreateBudgetInstancesService do
  describe '#self.call' do
    subject(:call) { described_class.call }

    context 'when budget instances are created correctly' do
      let!(:budget1) { create(:budget, :absolute) }
      let!(:budget2) { create(:budget, :absolute) }

      it 'creates all expected budget_instances' do
        expect { call }.to change { BudgetInstance.count }.by(2)
        new_budget_instances = BudgetInstance.last(2)
        expect(new_budget_instances.first.budget).to eq(budget1)
        expect(new_budget_instances.second.budget).to eq(budget2)
      end
    end

    context 'when there is an error creating a budget instance' do
      let!(:budget1) { create(:budget, :absolute) }
      let!(:budget2) { create(:budget, :absolute) }

      before do
        allow(BudgetInstance).to receive(:build_from_budget).and_call_original
        allow(BudgetInstance).to receive(:build_from_budget).with(budget1).and_raise(ActiveRecord::RecordInvalid)
      end

      it 'still creates the instances that succeeded and reports error to NewRelic' do
        expect(NewRelic::Agent).to receive(:notice_error)
        expect { call }.to change { BudgetInstance.count }.by(1)
        expect(BudgetInstance.last.budget).to eq(budget2)
      end
    end
  end
end
