# frozen_string_literal: true

RSpec.describe ProfileShare do
  subject { profile_share }

  let(:profile_share) { build(:profile_share) }

  describe '#validate_no_owner_self_sharing' do
    subject(:errors) do
      profile_share.valid?
      profile_share.errors
    end

    let(:profile_share) { build(:profile_share, user:, profile:) }

    context 'when the user is different from the profile user' do
      let(:user) { create(:user) }
      let(:profile) { create(:profile) }

      it { is_expected.to be_empty }
    end

    context 'when both user and profile user are the same' do
      let(:user) { create(:user) }
      let(:profile) { create(:profile, user:) }

      it 'adds an error to the user attribute' do
        expect(errors.size).to eq(1)
        expect(errors.first.type).to eq :owner_self_share
      end
    end
  end
end
