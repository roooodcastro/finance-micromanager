# frozen_string_literal: true

RSpec.describe BudgetInstanceSearch, type: :search do
  describe '.search' do
    subject(:search_results) { described_class.new(relation, query_params).search }

    let(:relation) { BudgetInstance.all }
    let(:query_params) { {} }

    context 'when a custom relation is passed to the class' do
      let(:relation) { BudgetInstance.where(profile:) }
      let(:profile) { create(:profile) }
      let!(:budget_instance_a) { create(:budget_instance, profile:) }

      before { create(:budget_instance) }

      it { is_expected.to contain_exactly(budget_instance_a) }
    end

    context 'when owner_type is specified' do
      let(:query_params) { { owner_type: 'Category' } }

      let(:profile) { create(:profile) }
      let(:category) { create(:category) }
      let!(:budget_instance_a) { create(:budget_instance, owner: category) }
      let!(:budget_instance_b) { create(:budget_instance, owner: profile) }

      it { is_expected.to include(budget_instance_a) }
      it { is_expected.not_to include(budget_instance_b) }
    end

    context 'when owner_id is specified' do
      let(:query_params) { { owner_id: category.id } }

      let(:category) { create(:category) }
      let!(:budget_instance_a) { create(:budget_instance, owner: category) }
      let!(:budget_instance_b) { create(:budget_instance) }

      it { is_expected.to include(budget_instance_a) }
      it { is_expected.not_to include(budget_instance_b) }
    end

    context 'when start_date is specified' do
      let(:query_params) { { start_date: Time.current } }

      let(:budget_instance_a) { create(:budget_instance, start_date: 1.month.ago.beginning_of_month) }
      let(:budget_instance_b) { create(:budget_instance, start_date: Time.current.beginning_of_month) }
      let(:budget_instance_c) { create(:budget_instance, start_date: 1.month.from_now.beginning_of_month) }

      it { is_expected.to include(budget_instance_a) }
      it { is_expected.to include(budget_instance_b) }
      it { is_expected.not_to include(budget_instance_c) }
    end

    context 'when end_date is specified' do
      let(:query_params) { { end_date: Time.current } }

      let(:budget_instance_a) { create(:budget_instance, end_date: 1.month.ago.end_of_month.end_of_day) }
      let(:budget_instance_b) { create(:budget_instance, end_date: Time.current.end_of_month.end_of_day) }
      let(:budget_instance_c) { create(:budget_instance, end_date: 1.month.from_now.end_of_month.end_of_day) }

      it { is_expected.not_to include(budget_instance_a) }
      it { is_expected.to include(budget_instance_b) }
      it { is_expected.to include(budget_instance_c) }
    end
  end
end
