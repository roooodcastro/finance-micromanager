# frozen_string_literal: true

RSpec.describe Budgets::UpdateBudgetInstancesAmountsService, :aggregate_failures do
  describe '#self.call' do
    subject(:call) { described_class.call(profile) }

    let(:profile) { create(:profile) }
    let(:category1) { create(:category, profile:) }
    let(:category2) { create(:category, profile:) }
    let(:category3) { create(:category, :income, profile:) }
    let!(:budget_instance) do
      budget_instance = create(:budget_instance, :from_budget, profile:, budget:)
      budget_instance.update(limit_amount: 10)
      budget_instance
    end

    let(:profile_budget) { create(:budget, :percentage, profile: profile, owner: profile, limit_percentage: 50) }
    let!(:profile_budget_instance) { create(:budget_instance, :from_budget, profile: profile, budget: profile_budget) }

    before do
      create(:transaction, profile: profile, amount: 100, skip_budget_recalculation: true)
      create(:transaction, profile: profile, category: category1, amount: -10, skip_budget_recalculation: true)
      create(:transaction, profile: profile, category: category2, amount: -105, skip_budget_recalculation: true)
      create(:transaction, profile: profile, category: category3, amount: -25, skip_budget_recalculation: true)
    end

    context 'for an absolute budget' do
      let(:budget) { create(:budget, :absolute, profile: profile, owner: category1, limit_amount: 60) }

      it 'updates the budget instance used amount with the new transactions sum for that category' do
        expect { call }
          .to change { budget_instance.reload.used_amount.to_f }
          .by(10)
          .and not_change { budget_instance.limit_amount.to_f }
      end

      it 'updates the profile budget used amount' do
        expect { call }.to change { profile_budget_instance.reload.used_amount.to_f }.to(15)
      end
    end

    context 'for an absolute budget with a carryover but with no instance last month' do
      let(:budget) { create(:budget, :absolute, profile: profile, owner: category1, limit_amount: 10, carryover: true) }

      it 'updates the profile budget used amount with the carryover from the previous month' do
        expect { call }
          .to change { budget_instance.reload.used_amount.to_f }
          .by(10)
      end
    end

    context 'for an absolute budget with a carryover from last month' do
      let(:budget) { create(:budget, :absolute, profile: profile, owner: category1, limit_amount: 10, carryover: true) }

      before do
        create(
          :budget_instance,
          :from_budget,
          budget:      budget,
          profile:     profile,
          used_amount: 5,
          start_date:  1.month.ago.beginning_of_month,
          end_date:    1.month.ago.end_of_month.end_of_day
        )
      end

      it 'updates the profile budget used amount with the carryover from the previous month' do
        expect { call }
          .to change { budget_instance.reload.used_amount.to_f }
          .by(5)
      end
    end

    context 'for a percentage budget' do
      let(:budget) { create(:budget, :percentage, profile: profile, owner: category1, limit_percentage: 25) }

      it 'updates the budget instance limit and used amount with the new transactions sum for that category' do
        expect { call }
          .to change { budget_instance.reload.limit_amount.to_f }
          .to(12.5)
          .and change { budget_instance.used_amount.to_f }
          .by(10)
      end
    end

    context 'for a remainder budget when profile budget is present' do
      let(:budget) { create(:budget, :remainder, profile: profile, owner: category1) }

      before do
        # Total profile budget is 50, minus this 30 should yield 20 for the remainder
        budget = create(:budget, :absolute, profile: profile, limit_amount: 30, owner: create(:category, profile:))
        create(:budget_instance, :from_budget, profile: profile, budget: budget, limit_amount: 100)
      end

      it 'updates the budget instance limit and used amount with the new transactions sum for that category' do
        expect { call }
          .to change { budget_instance.reload.limit_amount.to_f }
          .to(20)
          .and change { budget_instance.used_amount.to_f }
          .by(10)
      end
    end

    context 'for a remainder budget when profile budget is absent' do
      let(:budget) { create(:budget, :remainder, profile: profile, owner: category1) }
      let(:profile_budget) { nil }
      let(:profile_budget_instance) { nil }

      it 'updates the budget instance limit and used amount with the new transactions sum for that category' do
        expect { call }
          .to change { budget_instance.reload.limit_amount.to_f }
          .to(100)
          .and change { budget_instance.used_amount.to_f }
          .by(10)
      end
    end

    context 'when an error is raised' do
      let(:budget) { create(:budget, :absolute, profile: profile, owner: category1) }

      before { allow(Transaction).to receive(:where).and_raise(ActiveRecord::RecordInvalid) }

      it 'reports the error to NewRelic' do
        expect(NewRelic::Agent).to receive(:notice_error)
        call
      end
    end
  end
end
