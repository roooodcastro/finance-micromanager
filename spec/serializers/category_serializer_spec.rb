# frozen_string_literal: true

RSpec.describe CategorySerializer, type: :serializer do
  describe '.as_json' do
    subject(:json) { serializer.as_json(include_summary:) }

    let(:serializer) { described_class.new(category) }
    let(:category) { create(:category) }
    let(:include_summary) { false }

    context 'when nothing extra should be included' do
      let(:expected_json) do
        category.as_json.merge(
          subcategories: [],
          profile:       category.profile.as_json
        )
      end

      it { is_expected.to eq expected_json }
    end

    context 'when summary should be included' do
      let(:include_summary) { true }
      let!(:subcategory) { create(:subcategory, category:) }

      let(:expected_json) do
        category.as_json.merge(
          subcategories:         [subcategory.as_json],
          profile:               category.profile.as_json,
          summary:               { credit_amount: '€3.00', debit_amount: '€-5.00' },
          subcategories_summary: { subcategory.id => { spends_amount: -5, income_amount: 3, balance_amount: -2 } }
        )
      end

      before do
        create(:transaction, category: category, subcategory: subcategory, amount: -5)
        create(:transaction, category: category, subcategory: subcategory, amount: 3)
      end

      it { is_expected.to eq expected_json }
    end
  end
end
