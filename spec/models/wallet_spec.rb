# frozen_string_literal: true

RSpec.describe Wallet do
  subject { wallet }

  let(:wallet) { build(:wallet) }

  describe 'basic validation' do
    it { is_expected.to be_valid }
  end
end
