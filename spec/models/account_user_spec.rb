# frozen_string_literal: true

RSpec.describe AccountUser do
  subject { account_user }

  let(:account_user) { build(:account_user) }

  describe '#validate_no_owner_self_sharing' do
    subject(:errors) do
      account_user.valid?
      account_user.errors
    end

    let(:account_user) { build(:account_user, user:, account:) }

    context 'when the user is different from the account user' do
      let(:user) { create(:user) }
      let(:account) { create(:account) }

      it { is_expected.to be_empty }
    end

    context 'when both user and account user are the same' do
      let(:user) { create(:user) }
      let(:account) { create(:account, user:) }

      it 'adds an error to the user attribute' do
        expect(errors.size).to eq(1)
        expect(errors.first.type).to eq :owner_self_share
      end
    end
  end
end
