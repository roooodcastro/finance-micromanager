# frozen_string_literal: true

RSpec.describe SubCategory do
  subject { sub_category }

  let(:sub_category) { build(:sub_category) }

  describe 'basic validation' do
    it { is_expected.to be_valid }
  end
end
