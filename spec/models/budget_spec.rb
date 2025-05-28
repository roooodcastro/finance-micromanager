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
end
