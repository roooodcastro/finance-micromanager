# frozen_string_literal: true

RSpec.describe Profile do
  subject { profile }

  let(:profile) { build(:profile, currency: :eur) }

  describe '#validate_currency_stays_the_same' do
    context 'when creating a new profile' do
      it 'does not raise any errors' do
        profile.save
        expect(profile).to be_persisted
        expect(profile.errors).to be_empty
      end
    end

    context 'when updating the profile name' do
      before { profile.save! }

      it 'does not raise any errors' do
        expect { profile.update(name: 'Another name') }.to change { profile.reload.name }.to 'Another name'
        expect(profile.errors).to be_empty
      end
    end

    context 'when updating the profile currency' do
      before { profile.save! }

      it 'raises an error saying currency cannot be updated' do
        expect { profile.update(currency: :brl) }.to not_change { profile.reload.currency }
        expect(profile.errors[:currency]).to be_present
      end
    end
  end

  describe '.as_json' do
    subject { profile.as_json.deep_symbolize_keys }

    let(:profile) { create(:profile, currency: :eur, name: 'acc') }
    let(:user) { profile.user }

    let(:expected_user_json) do
      {
        default_profile_id: user.default_profile_id,
        display_name:       user.display_name,
        email:              user.email,
        first_name:         user.first_name,
        full_name:          user.full_name,
        id:                 user.id,
        last_name:          user.last_name
      }
    end

    let(:expected_profile_json) do
      {
        id:                   profile.id,
        name:                 'acc',
        display_name:         'acc',
        balance_amount_cents: 0,
        currency:             'eur',
        status:               'active',
        shared:               false,
        user_id:              profile.user_id,
        user:                 expected_user_json,
        currency_object:      { name: 'Euro', symbol: '€' },
        default_wallet_id:    nil
      }
    end

    before { Current.user = user }

    it { is_expected.to eq(expected_profile_json) }
  end

  describe '.currency_object' do
    subject { profile.currency_object }

    it { is_expected.to eq Money::Currency.find(:eur) }
  end

  describe '.display_name' do
    subject { profile.display_name }

    context 'when name is nil' do
      let(:profile) { build(:profile, currency: :eur, name: nil) }

      it { is_expected.to eq 'Euro' }
    end

    context 'when name is an empty string' do
      let(:profile) { build(:profile, currency: :eur, name: '') }

      it { is_expected.to eq 'Euro' }
    end

    context 'when name is present' do
      let(:profile) { build(:profile, currency: :eur, name: 'My name') }

      it { is_expected.to eq 'My name' }
    end
  end

  describe '.shared?' do
    subject { profile.shared? }

    context 'when profile owner is the logged in user' do
      before { Current.user = profile.user }

      it { is_expected.to be(false) }
    end

    context 'when profile owner is someone else' do
      before { Current.user = create(:user) }

      it { is_expected.to be(true) }
    end
  end
end
