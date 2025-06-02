# frozen_string_literal: true

RSpec.describe BudgetInstance do
  describe '#self.build_from_budget' do
    subject(:budget_instance) { described_class.build_from_budget(budget) }

    context 'for an absolute budget' do
      let(:budget) { create(:budget, :absolute) }

      it 'assigns attributes correctly' do
        expect(budget_instance.budget).to eq(budget)
        expect(budget_instance.budget.profile).to eq(budget.profile)
        expect(budget_instance.budget.limit_type).to eq(budget.limit_type)
        expect(budget_instance.budget.limit_amount).to eq(budget.limit_amount)
        expect(budget_instance.budget.limit_percentage).to eq(budget.limit_percentage)
        expect(budget_instance.budget.owner).to eq(budget.owner)
      end
    end

    context 'for a percentage budget' do
      let(:budget) { create(:budget, :percentage, owner: category) }
      let(:category) { create(:category) }

      it 'assigns attributes correctly' do
        expect(budget_instance.budget).to eq(budget)
        expect(budget_instance.budget.profile).to eq(budget.profile)
        expect(budget_instance.budget.limit_type).to eq(budget.limit_type)
        expect(budget_instance.budget.limit_amount).to eq(budget.limit_amount)
        expect(budget_instance.budget.limit_percentage).to eq(budget.limit_percentage)
        expect(budget_instance.budget.owner).to eq(category)
      end
    end
  end
end
