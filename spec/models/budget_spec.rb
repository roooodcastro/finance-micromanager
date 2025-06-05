# frozen_string_literal: true

RSpec.describe Budget do
  describe '#formatted_limit' do
    subject { budget.formatted_limit }

    let(:profile) { create(:profile) }

    context 'when the limit type is absolute' do
      let(:budget) { build(:budget, :absolute, profile: profile, limit_amount: 35.5) }

      it { is_expected.to eq '€35.50' }
    end

    context 'when the limit type is percentage' do
      let(:budget) { build(:budget, :percentage, profile: profile, limit_percentage: 15) }

      it { is_expected.to eq '15.0%' }
    end

    context 'when the limit type is remainder' do
      let(:budget) { build(:budget, :remainder, profile:) }

      it { is_expected.to eq 'Remainder' }
    end
  end

  describe '#build_budget' do
    subject(:build_budget) { described_class.build_budget(params) }

    let(:profile) { create(:profile) }
    let(:params) { { limit_type: 'absolute', limit_amount: 500, owner_id: owner_id, owner_type: owner_type } }

    before { allow(Current).to receive(:profile).and_return(profile) }

    context 'when the budget is for the profile and there are no existing budgets for the profile' do
      let(:owner_id) { profile.id }
      let(:owner_type) { profile.class.name }

      it 'instantiates a new Budget with the provided attributes' do
        expect(build_budget.attributes).to eq(
          'id'                 => nil,
          'profile_id'         => profile.id,
          'owner_type'         => owner_type,
          'owner_id'           => owner_id,
          'limit_type'         => 'absolute',
          'limit_amount_cents' => 500_00,
          'limit_percentage'   => nil,
          'disabled_at'        => nil,
          'disabled_by_id'     => nil,
          'created_at'         => nil,
          'updated_at'         => nil
        )
      end
    end

    context 'when the budget is for the profile and the profile already has a disabled budget' do
      let(:owner_id) { profile.id }
      let(:owner_type) { profile.class.name }
      let!(:budget) { create(:budget, :disabled, profile: profile, owner: profile) }

      it 'returns the existing budget with updated attributes' do
        expect(build_budget.attributes).to eq(
          'id'                 => budget.id,
          'profile_id'         => profile.id,
          'owner_type'         => owner_type,
          'owner_id'           => owner_id,
          'limit_type'         => 'absolute',
          'limit_amount_cents' => 500_00,
          'limit_percentage'   => nil,
          'disabled_at'        => nil,
          'disabled_by_id'     => nil,
          'created_at'         => budget.created_at,
          'updated_at'         => budget.updated_at
        )
      end
    end

    context 'when the budget is for a category' do
      let(:category) { create(:category, profile:) }

      let(:owner_id) { category.id }
      let(:owner_type) { category.class.name }

      it 'instantiates a new Budget with the provided attributes' do
        expect(build_budget.attributes).to eq(
          'id'                 => nil,
          'profile_id'         => profile.id,
          'owner_type'         => owner_type,
          'owner_id'           => owner_id,
          'limit_type'         => 'absolute',
          'limit_amount_cents' => 500_00,
          'limit_percentage'   => nil,
          'disabled_at'        => nil,
          'disabled_by_id'     => nil,
          'created_at'         => nil,
          'updated_at'         => nil
        )
      end
    end
  end
end
