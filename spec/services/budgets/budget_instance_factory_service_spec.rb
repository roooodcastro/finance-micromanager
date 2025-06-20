# frozen_string_literal: true

RSpec.describe Budgets::BudgetInstanceFactoryService do
  describe '#self.call' do
    subject(:budget_instance) { described_class.call(budget, reference_date) }

    let(:reference_date) { Time.current }
    let(:category) { create(:category) }

    context 'for an absolute budget' do
      let(:budget) { create(:budget, :absolute, limit_amount: 50) }

      it 'assigns attributes correctly' do
        expect(budget_instance.budget).to eq(budget)
        expect(budget_instance.profile).to eq(budget.profile)
        expect(budget_instance.limit_type).to eq('absolute')
        expect(budget_instance.limit_amount.to_f).to eq(50)
        expect(budget_instance.used_amount.to_f).to eq(0)
        expect(budget_instance.limit_percentage).to be_nil
        expect(budget_instance.owner).to eq(budget.owner)
        expect(budget_instance.start_date).to be_within(1.second).of(Time.current.beginning_of_month)
        expect(budget_instance.end_date).to be_within(1.second).of(Time.current.end_of_month.end_of_day)
      end
    end

    context 'for a percentage budget' do
      let(:budget) { create(:budget, :percentage, owner: category, limit_percentage: 20.5) }

      it 'assigns attributes correctly' do
        expect(budget_instance.budget).to eq(budget)
        expect(budget_instance.profile).to eq(budget.profile)
        expect(budget_instance.limit_type).to eq('percentage')
        expect(budget_instance.limit_amount.to_f).to eq(0)
        expect(budget_instance.used_amount.to_f).to eq(0)
        expect(budget_instance.limit_percentage).to eq(20.5)
        expect(budget_instance.owner).to eq(category)
        expect(budget_instance.start_date).to be_within(1.second).of(Time.current.beginning_of_month)
        expect(budget_instance.end_date).to be_within(1.second).of(Time.current.end_of_month.end_of_day)
      end
    end

    context 'for a remainder budget' do
      let(:budget) { create(:budget, :remainder, owner: category) }

      it 'assigns attributes correctly' do
        expect(budget_instance.budget).to eq(budget)
        expect(budget_instance.profile).to eq(budget.profile)
        expect(budget_instance.limit_type).to eq('remainder')
        expect(budget_instance.limit_amount.to_f).to eq(0)
        expect(budget_instance.used_amount.to_f).to eq(0)
        expect(budget_instance.limit_percentage).to be_nil
        expect(budget_instance.owner).to eq(category)
        expect(budget_instance.start_date).to be_within(1.second).of(Time.current.beginning_of_month)
        expect(budget_instance.end_date).to be_within(1.second).of(Time.current.end_of_month.end_of_day)
      end
    end

    context 'for a different reference date' do
      let(:budget) { create(:budget, :absolute, owner: category, limit_amount: 50) }
      let(:reference_date) { 2.months.ago }

      it 'assigns attributes correctly' do
        expect(budget_instance.budget).to eq(budget)
        expect(budget_instance.profile).to eq(budget.profile)
        expect(budget_instance.limit_type).to eq('absolute')
        expect(budget_instance.limit_amount.to_f).to eq(50)
        expect(budget_instance.used_amount.to_f).to eq(0)
        expect(budget_instance.limit_percentage).to be_nil
        expect(budget_instance.owner).to eq(category)
        expect(budget_instance.start_date).to be_within(1.second).of(2.months.ago.beginning_of_month)
        expect(budget_instance.end_date).to be_within(1.second).of(2.months.ago.end_of_month.end_of_day)
      end
    end

    context 'when there is a previous instance for the previous month and budget has carryover' do
      let(:budget) { create(:budget, :absolute, owner: category, limit_amount: 50, carryover: true) }

      before do
        create(:budget_instance, :from_budget, budget: budget, used_amount: 30,
               start_date: 1.month.ago.beginning_of_month, end_date: 1.month.ago.end_of_month.end_of_day)
      end

      it 'assigns attributes correctly' do
        expect(budget_instance.limit_amount.to_f).to eq(50)
        expect(budget_instance.used_amount.to_f).to eq(-20)
        expect(budget_instance.limit_percentage).to be_nil
        expect(budget_instance.start_date).to be_within(1.second).of(Time.current.beginning_of_month)
        expect(budget_instance.end_date).to be_within(1.second).of(Time.current.end_of_month.end_of_day)
      end
    end

    context 'when there is a previous instance for the previous month and budget does not have carryover' do
      let(:budget) { create(:budget, :absolute, owner: category, limit_amount: 50, carryover: false) }

      before do
        create(:budget_instance, :from_budget, budget: budget, used_amount: 30,
               start_date: 1.month.ago.beginning_of_month, end_date: 1.month.ago.end_of_month.end_of_day)
      end

      it 'assigns attributes correctly' do
        expect(budget_instance.limit_amount.to_f).to eq(50)
        expect(budget_instance.used_amount.to_f).to eq(0)
        expect(budget_instance.limit_percentage).to be_nil
        expect(budget_instance.start_date).to be_within(1.second).of(Time.current.beginning_of_month)
        expect(budget_instance.end_date).to be_within(1.second).of(Time.current.end_of_month.end_of_day)
      end
    end

    context 'when there is a previous instance for a month earlier than the previous month and budget has carryover' do
      let(:budget) { create(:budget, :percentage, owner: category, limit_percentage: 30, carryover: true) }

      before do
        create(:budget_instance, :from_budget, budget: budget, used_amount: 30,
               start_date: 2.months.ago.beginning_of_month, end_date: 2.months.ago.end_of_month.end_of_day)
      end

      it 'assigns attributes correctly' do
        expect(budget_instance.limit_amount.to_f).to eq(0)
        expect(budget_instance.used_amount.to_f).to eq(0)
        expect(budget_instance.limit_percentage).to eq(30)
        expect(budget_instance.start_date).to be_within(1.second).of(Time.current.beginning_of_month)
        expect(budget_instance.end_date).to be_within(1.second).of(Time.current.end_of_month.end_of_day)
      end
    end
  end
end
