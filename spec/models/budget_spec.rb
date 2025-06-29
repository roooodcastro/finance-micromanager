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
          'updated_at'         => nil,
          'carryover'          => false
        )
      end
    end

    context 'when the budget is for the profile and the profile already has a disabled budget' do
      let(:owner_id) { profile.id }
      let(:owner_type) { profile.class.name }
      let!(:budget) { create(:budget, :disabled, profile: profile, owner: profile, carryover: true) }

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
          'updated_at'         => budget.updated_at,
          'carryover'          => true
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
          'updated_at'         => nil,
          'carryover'          => false
        )
      end
    end
  end

  describe 'validate one budget per profile' do
    subject do
      budget.valid?
      budget.errors.messages
    end

    let(:profile) { create(:profile) }
    let(:budget) { build(:budget, profile: profile, owner: profile) }

    context 'when there are no other budgets in the profile' do
      it { is_expected.not_to have_key(:owner_id) }
    end

    context 'when there is already another profile budget' do
      before { create(:budget, profile: profile, owner: profile) }

      it { is_expected.to have_key(:owner_id) }
    end
  end

  describe 'validate one budget per category' do
    subject do
      budget.valid?
      budget.errors.messages
    end

    let(:profile) { create(:profile) }
    let(:category) { create(:category, profile:) }
    let(:budget) { build(:budget, profile: profile, owner: category) }

    context 'when there are no other budgets for the category' do
      it { is_expected.not_to have_key(:owner_id) }
    end

    context 'when there is already a budget for the category' do
      before { create(:budget, profile: profile, owner: category) }

      it { is_expected.to have_key(:owner_id) }
    end
  end

  describe 'validate one remainder category budget per profile' do
    subject do
      budget.valid?
      budget.errors.messages
    end

    let(:profile) { create(:profile) }
    let(:category) { create(:category, profile:) }
    let(:budget) { build(:budget, :remainder, profile: profile, owner: category) }

    context 'when there are no other budgets with type remainder in the profile' do
      it { is_expected.not_to have_key(:limit_type) }
    end

    context 'when there are already a remainder budget for the profile' do
      before { create(:budget, :remainder, :category, profile:) }

      it { is_expected.to have_key(:limit_type) }
    end
  end

  describe 'validate percentage inside bounds' do
    subject do
      budget.valid?
      budget.errors.messages
    end

    let(:profile) { create(:profile) }
    let(:budget) { build(:budget, :percentage, profile:, limit_percentage:) }

    context 'when percentage is negative' do
      let(:limit_percentage) { -1 }

      it { is_expected.to have_key(:limit_percentage) }
    end

    context 'when percentage is zero' do
      let(:limit_percentage) { 0 }

      it { is_expected.to have_key(:limit_percentage) }
    end

    context 'when percentage is between 0 and 99' do
      let(:limit_percentage) { 12.5 }

      it { is_expected.not_to have_key(:limit_percentage) }
    end

    context 'when percentage is 100' do
      let(:limit_percentage) { 100 }

      it { is_expected.not_to have_key(:limit_percentage) }
    end

    context 'when percentage is 101' do
      let(:limit_percentage) { 101 }

      it { is_expected.to have_key(:limit_percentage) }
    end
  end

  describe 'validate profile budget cannot be remainder' do
    subject do
      budget.valid?
      budget.errors.messages
    end

    context 'when profile budget is set as remainder' do
      let(:budget) { build(:budget, :profile, :remainder) }

      it { is_expected.to have_key(:limit_type) }
    end

    context 'when profile budget is not set as remainder' do
      let(:budget) { build(:budget, :profile, :absolute) }

      it { is_expected.not_to have_key(:limit_type) }
    end
  end

  describe 'validate absolute category budget limit_amount cannot be greater than absolute profile limit_amount' do
    subject(:error_messages) do
      budget.valid?
      budget.errors.messages
    end

    let(:profile) { create(:profile) }
    let(:budget) { build(:budget, :category, :absolute, profile:, limit_amount:) }

    before do
      create(:budget, :absolute, profile: profile, owner: profile, limit_amount: 100)
      profile.reload
    end

    context 'when limit_amount is nil' do
      let(:limit_amount) { nil }

      it 'does not raise a validation error' do
        expect(error_messages[:limit_amount]).not_to include('cannot be greater than the profile budget limit')
      end
    end

    context 'when the budget limit is lower than the profile limit' do
      let(:limit_amount) { 99 }

      it { is_expected.not_to have_key(:limit_amount) }
    end

    context 'when the budget limit is equal than the profile limit' do
      let(:limit_amount) { 100 }

      it { is_expected.not_to have_key(:limit_amount) }
    end

    context 'when the budget limit is greater than the profile limit' do
      let(:limit_amount) { 101 }

      it 'raises a validation error' do
        expect(error_messages[:limit_amount]).to include('cannot be greater than the profile budget limit')
      end
    end
  end

  describe 'validate absolute profile budget limit_amount cannot be less than absolute category budget limit_amount' do
    subject(:error_messages) do
      budget.valid?
      budget.errors.messages
    end

    let(:profile) { create(:profile) }
    let(:budget) { build(:budget, :absolute, profile: profile, owner: profile, limit_amount: limit_amount) }

    before { create(:budget, :category, :absolute, profile: profile, limit_amount: 100) }

    context 'when limit_amount is nil' do
      let(:limit_amount) { nil }

      it 'does not raise a validation error' do
        expect(error_messages[:limit_amount]).not_to include('cannot be less than the highest category budget limit')
      end
    end

    context 'when the profile budget limit is lower than the highest category budget limit' do
      let(:limit_amount) { 99 }

      it 'raises a validation error' do
        expect(error_messages[:limit_amount]).to include('cannot be less than the highest category budget limit')
      end
    end

    context 'when the profile budget limit is equal than the highest category budget limit' do
      let(:limit_amount) { 100 }

      it { is_expected.not_to have_key(:limit_amount) }
    end

    context 'when the profile budget limit is greater than the highest category budget limit' do
      let(:limit_amount) { 101 }

      it { is_expected.not_to have_key(:limit_amount) }
    end
  end
end
