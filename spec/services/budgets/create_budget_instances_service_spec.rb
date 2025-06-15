# frozen_string_literal: true

RSpec.describe Budgets::CreateBudgetInstancesService, :aggregate_failures do
  describe '#self.call' do
    subject(:call) { described_class.call }

    let(:profile) { create(:profile) }

    context 'when the profile has an absolute budget and the remainder is positive' do
      let(:category1) { create(:category, profile:) }
      let(:category2) { create(:category, profile:) }
      let(:category3) { create(:category, profile:) }

      before do
        create(:budget, :absolute, owner: profile, profile: profile, limit_amount: 1000)
        create(:budget, :absolute, owner: category1, profile: profile, limit_amount: 300)
        create(:budget, :percentage, owner: category2, profile: profile, limit_percentage: 50)
        create(:budget, :remainder, owner: category3, profile: profile)
      end

      it 'creates a budget_instance for the profile' do
        expect { call }.to change { BudgetInstance.count }.by_at_least(1)
        profile_budget_instance = BudgetInstance.find_by(owner: profile)
        expect(profile_budget_instance.limit_amount.to_f).to eq(1000)
      end

      it 'creates budget instances for each category, with the correct limit_amount in each of them' do
        expect { call }.to change { BudgetInstance.count }.by(4)
        cat1_budget_instance = BudgetInstance.find_by(owner: category1)
        cat2_budget_instance = BudgetInstance.find_by(owner: category2)
        cat3_budget_instance = BudgetInstance.find_by(owner: category3)
        expect(cat1_budget_instance.limit_amount.to_f).to eq(300)
        expect(cat2_budget_instance.limit_amount.to_f).to eq(500)
        expect(cat3_budget_instance.limit_amount.to_f).to eq(200)
      end
    end

    context 'when the profile has a percentage budget and no categories have remainder budgets' do
      let(:category1) { create(:category, profile:) }
      let(:category2) { create(:category, profile:) }

      before do
        create(:budget, :percentage, owner: profile, profile: profile, limit_percentage: 80)
        create(:budget, :absolute, owner: category1, profile: profile, limit_amount: 300)
        create(:budget, :percentage, owner: category2, profile: profile, limit_percentage: 50)
      end

      it 'creates a budget_instance for the profile' do
        expect { call }.to change { BudgetInstance.count }.by_at_least(1)
        profile_budget_instance = BudgetInstance.find_by(owner: profile)
        expect(profile_budget_instance.limit_amount.to_f).to eq(0)
      end

      it 'creates budget instances for each category, with the correct limit_amount in each of them' do
        expect { call }.to change { BudgetInstance.count }.by(3)
        cat1_budget_instance = BudgetInstance.find_by(owner: category1)
        cat2_budget_instance = BudgetInstance.find_by(owner: category2)
        expect(cat1_budget_instance.limit_amount.to_f).to eq(300)
        expect(cat2_budget_instance.limit_amount.to_f).to eq(0)
      end
    end

    context 'when the profile has a budget and the remainder is negative' do
      let(:category1) { create(:category, profile:) }
      let(:category2) { create(:category, profile:) }
      let(:category3) { create(:category, profile:) }

      before do
        create(:budget, :absolute, owner: profile, profile: profile, limit_amount: 1000)
        create(:budget, :absolute, owner: category1, profile: profile, limit_amount: 600)
        create(:budget, :percentage, owner: category2, profile: profile, limit_percentage: 50)
        create(:budget, :remainder, owner: category3, profile: profile)
      end

      it 'creates budget instances for each category, with the correct limit_amount in each of them' do
        expect { call }.to change { BudgetInstance.count }.by(4)
        cat1_budget_instance = BudgetInstance.find_by(owner: category1)
        cat2_budget_instance = BudgetInstance.find_by(owner: category2)
        cat3_budget_instance = BudgetInstance.find_by(owner: category3)
        expect(cat1_budget_instance.limit_amount.to_f).to eq(600)
        expect(cat2_budget_instance.limit_amount.to_f).to eq(500)
        expect(cat3_budget_instance.limit_amount.to_f).to eq(0)
      end
    end

    context 'when the profile does not have a budget' do
      let(:category1) { create(:category, profile:) }
      let(:category2) { create(:category, profile:) }
      let(:category3) { create(:category, profile:) }

      before do
        create(:budget, :absolute, owner: category1, profile: profile, limit_amount: 300)
        create(:budget, :percentage, owner: category2, profile: profile, limit_percentage: 20)
        create(:budget, :remainder, owner: category3, profile: profile)
      end

      it 'creates budget instances for each category, with the correct limit_amount in each of them' do
        expect { call }.to change { BudgetInstance.count }.by(3)
        cat1_budget_instance = BudgetInstance.find_by(owner: category1)
        cat2_budget_instance = BudgetInstance.find_by(owner: category2)
        cat3_budget_instance = BudgetInstance.find_by(owner: category3)
        expect(cat1_budget_instance.limit_amount.to_f).to eq(300)
        expect(cat2_budget_instance.limit_amount.to_f).to eq(0)
        expect(cat3_budget_instance.limit_amount.to_f).to eq(0)
      end
    end

    context 'when an error is raised' do
      before do
        allow(BudgetInstance).to receive(:build_from_budget).and_raise(ActiveRecord::RecordInvalid)
        create(:budget, :absolute, owner: profile, profile: profile)
      end

      it 'reports the error to NewRelic' do
        expect(NewRelic::Agent).to receive(:notice_error)
        call
      end
    end
  end
end
