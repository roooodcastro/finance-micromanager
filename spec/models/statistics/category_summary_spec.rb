# frozen_string_literal: true

RSpec.describe Statistics::CategorySummary do
  let(:category_summary) do
    described_class.new(category_id:, profile_id:, currency_name:, credit_sum_cents:, debit_sum_cents:, subcategory_id:)
  end

  let(:category_id) { SecureRandom.uuid }
  let(:subcategory_id) { SecureRandom.uuid }
  let(:profile_id) { SecureRandom.uuid }
  let(:currency_name) { 'brl' }
  let(:credit_sum_cents) { 499 }
  let(:debit_sum_cents) { -712_550 }

  describe '.credit_sum' do
    subject { category_summary.credit_sum }

    it { is_expected.to eq 4.99 }
  end

  describe '.debit_sum' do
    subject { category_summary.debit_sum }

    it { is_expected.to eq(-7125.5) }
  end

  describe '.formatted_credit_sum' do
    subject { category_summary.formatted_credit_sum }

    around { |spec| I18n.with_locale(locale) { spec.run } }

    context 'for en locale' do
      let(:locale) { 'en' }

      it { is_expected.to eq 'R$4.99' }
    end

    context 'for pt-BR locale' do
      let(:locale) { 'pt-BR' }

      it { is_expected.to eq 'R$4,99' }
    end
  end

  describe '.formatted_debit_sum' do
    subject { category_summary.formatted_debit_sum }

    around { |spec| I18n.with_locale(locale) { spec.run } }

    context 'for en locale' do
      let(:locale) { 'en' }

      it { is_expected.to eq 'R$-7,125.50' }
    end

    context 'for pt-BR locale' do
      let(:locale) { 'pt-BR' }

      it { is_expected.to eq 'R$-7.125,50' }
    end
  end

  describe '.as_json' do
    subject { category_summary.as_json }

    let(:expected_id) { 'test-uuid' }

    let(:expected_json) do
      {
        id:             expected_id,
        credit_sum:     4.99,
        debit_sum:      -7125.5,
        currency:       'brl',
        currency_code:  'BRL',
        category_id:    category_id,
        profile_id:     profile_id,
        subcategory_id: subcategory_id
      }
    end

    before do
      category_id
      profile_id
      allow(SecureRandom).to receive(:uuid).and_return(expected_id)
    end

    it { is_expected.to eq expected_json }
  end
end
