# frozen_string_literal: true

RSpec.describe Subcategory do
  subject { subcategory }

  let(:subcategory) { build(:subcategory) }

  describe 'basic validation' do
    it { is_expected.to be_valid }
  end
end
