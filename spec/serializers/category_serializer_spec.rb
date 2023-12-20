# frozen_string_literal: true

RSpec.describe CategorySerializer, type: :serializer do
  describe '.as_json' do
    subject(:json) { serializer.as_json(include_summary:, include_recent_transactions:) }

    let(:serializer) { described_class.new(category) }
    let(:category) { create(:category) }
    let(:include_summary) { false }
    let(:include_recent_transactions) { false }

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

      let(:expected_json) do
        category.as_json.merge(
          subcategories: [],
          profile:       category.profile.as_json,
          summary:       { credit_amount: '€3.00', debit_amount: '€-5.00' }
        )
      end

      before do
        create(:transaction, category: category, amount: -5)
        create(:transaction, category: category, amount: 3)
      end

      it { is_expected.to eq expected_json }
    end

    context 'when recent transactions should be included' do
      let!(:transaction_a) { create(:transaction, category: category, amount: -5, transaction_date: 1.day.ago) }
      let!(:transaction_b) { create(:transaction, category: category, amount: 3, transaction_date: 2.days.ago) }
      let(:include_recent_transactions) { true }

      let(:expected_json) do
        category.as_json.merge(
          subcategories:       [],
          profile:             category.profile.as_json,
          recent_transactions: [transaction_a.as_json, transaction_b.as_json]
        )
      end

      it { is_expected.to eq expected_json }
    end
  end
end
