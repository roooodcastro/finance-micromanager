# frozen_string_literal: true

RSpec.describe User do
  subject { user }

  let(:user) { build(:user) }

  describe 'default_account_validation' do
    context 'for a new User' do
      let(:user) { build(:user) }

      context 'when the user does not have a default account' do
        before { user.default_account = nil }

        it { is_expected.to be_valid }
      end

      context 'when the user has a default account' do
        it { is_expected.to be_valid }
      end
    end

    context 'for an existing User' do
      let(:user) { create(:user) }

      context 'when the user does not have a default account' do
        before { user.default_account = nil }

        it { is_expected.not_to be_valid }
      end

      context 'when the user has a default account' do
        it { is_expected.to be_valid }
      end
    end
  end

  describe '#set_default_account' do
    subject(:user_save) { user.save }

    context 'when default account exists' do
      let!(:account) { create(:account, user:) }

      before { user.default_account = account }

      it 'does not create or set anything' do
        expect { user_save }.to not_change { Account.count }.and not_change { user.default_account }
      end
    end

    context 'when default account is nil' do
      let(:user) { build(:user, default_account: nil) }

      it 'creates the default account' do
        expect { user_save }.to change { Account.count }.by(1)

        new_account = Account.last

        expect(new_account.user).to eq user
        expect(new_account.status).to eq 'active'
        expect(new_account.currency).to eq 'eur'
        expect(user.reload.default_account).to eq new_account
      end
    end
  end

  describe '.find_available_account' do
    subject(:find_available_account) { user.find_available_account(id) }

    let(:user) { create(:user) }

    context 'when the account cannot be found' do
      let(:id) { 'unknown' }

      it 'raises a RecordNotFound exception' do
        expect { find_available_account }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when the account is found in the user own accounts' do
      let!(:account) { create(:account, user:) }
      let(:id) { account.id }

      it { is_expected.to eq account }
    end

    context 'when the account is found in the user shared accounts' do
      let!(:account) do
        new_account = create(:account)
        create(:account_user, account: new_account, user: user)
        new_account
      end

      let(:id) { account.id }

      it { is_expected.to eq account }
    end
  end
end
