# frozen_string_literal: true

RSpec.describe Budgets::UpdateProfileBudgetInstancesService, :aggregate_failures do
  describe '#self.call' do
    subject(:call) { described_class.call(profile) }

    let(:profile) { create(:profile) }
    let(:category) { create(:category, profile:) }
    let!(:budget_instance) { create(:budget_instance, :from_budget, profile:, budget:) }
    let!(:profile_budget) do # rubocop:disable RSpec/LetSetup
      profile_budget = create(:budget, :percentage, profile: profile, owner: profile, limit_percentage: 50)
      create(:budget_instance, :from_budget, profile: profile, budget: profile_budget)
    end

    before do
      create(:transaction, profile: profile, amount: 100, skip_budget_recalculation: true)
      create(:transaction, profile: profile, category: category, amount: -10, skip_budget_recalculation: true)
    end

    context 'for an absolute budget' do
      let(:budget) { create(:budget, :absolute, profile: profile, owner: category) }

      it 'updates the budget instance used amount with the new transactions sum for that category' do
        expect { call }
          .to change { budget_instance.reload.used_amount.to_f }
          .by(10)
          .and not_change { budget_instance.limit_amount.to_f }
      end
    end

    context 'for a percentage budget' do
      let(:budget) { create(:budget, :percentage, profile: profile, owner: category, limit_percentage: 25) }

      it 'updates the budget instance limit and used amount with the new transactions sum for that category' do
        expect { call }
          .to change { budget_instance.reload.limit_amount.to_f }
          .to(12.5)
          .and change { budget_instance.used_amount.to_f }
          .by(10)
      end
    end

    context 'for a remainder budget when profile budget is present' do
      let(:budget) { create(:budget, :remainder, profile: profile, owner: category) }

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
      let(:budget) { create(:budget, :remainder, profile: profile, owner: category) }
      let(:profile_budget) { nil }

      it 'updates the budget instance limit and used amount with the new transactions sum for that category' do
        expect { call }
          .to change { budget_instance.reload.limit_amount.to_f }
          .to(100)
          .and change { budget_instance.used_amount.to_f }
          .by(10)
      end
    end

    context 'when an error is raised' do
      let(:budget) { create(:budget, :absolute, profile: profile, owner: category) }

      before { allow(Transaction).to receive(:where).and_raise(ActiveRecord::RecordInvalid) }

      it 'reports the error to NewRelic' do
        expect(NewRelic::Agent).to receive(:notice_error)
        call
      end
    end
  end
end
