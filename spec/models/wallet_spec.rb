# frozen_string_literal: true

RSpec.describe Wallet do
  subject { wallet }

  let(:wallet) { build(:wallet) }

  describe 'basic validation' do
    it { is_expected.to be_valid }
  end

  describe '.disable!', :travel_to_now do
    subject(:disable_method) { wallet.disable! }

    let(:wallet) { create(:wallet, balance:) }
    let(:now) { Time.current.change(usec: 0) }
    let(:user) { create(:user) }

    before { allow(Current).to receive(:user).and_return(user) }

    context 'when wallet balance is zero' do
      let(:balance) { 0 }

      it 'disables the wallet' do
        expect { disable_method }
          .to change { wallet.reload.disabled_at }
          .to(now)
          .and change { wallet.disabled_by }
          .to(user)
      end
    end

    context 'when wallet balance is not zero' do
      let(:balance) { -1.5 }

      it 'does not disable the wallet' do
        expect { disable_method }
          .to not_change { wallet.reload.disabled_at }
          .and not_change { wallet.disabled_by }

        expect(wallet.errors[:base].first).to start_with('Cannot be disabled because wallet has remaining balance.')
      end
    end
  end
end
