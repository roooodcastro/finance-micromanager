# frozen_string_literal: true

RSpec.describe User do
  subject { user }

  let(:user) { build(:user) }

  describe 'default_profile_validation' do
    context 'for a new User' do
      let(:user) { build(:user) }

      context 'when the user does not have a default profile' do
        before { user.default_profile = nil }

        it { is_expected.to be_valid }
      end

      context 'when the user has a default profile' do
        it { is_expected.to be_valid }
      end
    end

    context 'for an existing User' do
      let(:user) { create(:user) }

      context 'when the user does not have a default profile' do
        before { user.default_profile = nil }

        it { is_expected.not_to be_valid }
      end

      context 'when the user has a default profile' do
        it { is_expected.to be_valid }
      end
    end
  end

  describe '#set_default_profile' do
    subject(:user_save) { user.save }

    context 'when default profile exists' do
      let!(:profile) { create(:profile, user:) }

      before { user.default_profile = profile }

      it 'does not create or set anything' do
        expect { user_save }.to not_change { Profile.count }.and not_change { user.default_profile }
      end
    end

    context 'when default profile is nil' do
      let(:user) { build(:user, default_profile: nil) }

      it 'creates the default profile' do
        expect { user_save }.to change { Profile.count }.by(1)

        new_profile = Profile.last

        expect(new_profile.user).to eq user
        expect(new_profile.status).to eq 'active'
        expect(new_profile.currency).to eq 'eur'
        expect(user.reload.default_profile).to eq new_profile
      end
    end
  end

  describe '.full_name' do
    subject { user.full_name }

    context 'when first name and last name are present' do
      let(:user) { described_class.new(first_name: 'First', last_name: 'Last') }

      it { is_expected.to eq 'First Last' }
    end

    context 'when first nam eand last name are absent' do
      let(:user) { described_class.new(email: 'test@email.com') }

      it { is_expected.to eq 'test@email.com' }
    end
  end

  describe '.find_available_profile' do
    subject(:find_available_profile) { user.find_available_profile(id) }

    let(:user) { create(:user) }

    context 'when the profile cannot be found' do
      let(:id) { 'unknown' }

      it 'raises a RecordNotFound exception' do
        expect { find_available_profile }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when the profile is found in the user own profiles' do
      let!(:profile) { create(:profile, user:) }
      let(:id) { profile.id }

      it { is_expected.to eq profile }
    end

    context 'when the profile is found in the user shared profiles' do
      let!(:profile) do
        new_profile = create(:profile)
        create(:profile_share, profile: new_profile, user: user)
        new_profile
      end

      let(:id) { profile.id }

      it { is_expected.to eq profile }
    end
  end
end
