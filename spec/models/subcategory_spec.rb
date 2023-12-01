# frozen_string_literal: true

RSpec.describe Subcategory do
  subject { subcategory }

  let(:subcategory) { build(:subcategory) }

  describe 'basic validation' do
    it { is_expected.to be_valid }
  end

  describe '.display_name' do
    subject { subcategory.display_name }

    let(:category) { build(:category, name: 'My Cat') }
    let(:subcategory) { build(:subcategory, category: category, name: 'My SubCat') }

    it { is_expected.to eq 'My Cat/My SubCat' }
  end
end
