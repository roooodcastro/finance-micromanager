# frozen_string_literal: true

RSpec.describe TransactionImports::ImportTransaction do
  let(:profile) { create(:profile, currency: :brl) }
  let(:import) { create(:import, profile:) }
  let(:import_transaction) { described_class.new(import:) }

  describe '#currency' do
    subject { import_transaction.currency }

    context 'when the profile has a currency' do
      it { is_expected.to eq('brl') }
    end

    context 'when the profile is empty' do
      let(:import_transaction) { described_class.new }

      it { is_expected.to eq('eur') }
    end
  end

  describe '#assign_match_transaction', :aggregate_failures do
    subject(:assign_match_transaction) { import_transaction.assign_match_transaction(match_transaction) }

    let(:category) { create(:category, profile:) }
    let(:subcategory) { create(:subcategory, category:) }

    context 'when match_transaction exists' do
      let(:match_transaction) do
        create(
          :transaction,
          profile:          profile,
          name:             'A Name',
          amount:           123,
          transaction_date: '2024-09-01',
          category:         category,
          subcategory:      subcategory
        )
      end

      it 'assigns all relevant attributes' do
        expect { assign_match_transaction }
          .to change { import_transaction.name }
          .to('A Name')
          .and change { import_transaction.transaction_date }
          .to(Date.parse('2024-09-01'))
          .and change { import_transaction.amount.to_f }
          .to(123)
          .and change { import_transaction.category }
          .to(category)
          .and change { import_transaction.subcategory }
          .to(subcategory)
      end
    end

    context 'when match_transaction is nil' do
      let(:match_transaction) { nil }

      let(:import_transaction) do
        described_class.new(
          import:               import,
          category:             category,
          subcategory:          subcategory,
          name:                 'A Name',
          original_import_name: 'Original Name',
          amount:               123,
          transaction_date:     '2024-09-01'
        )
      end

      it 'assigns all relevant attributes' do
        expect { assign_match_transaction }
          .to change { import_transaction.name }
          .to('Original Name')
          .and not_change { import_transaction.transaction_date }
          .and not_change { import_transaction.amount.to_f }
          .and change { import_transaction.category }
          .to(nil)
          .and change { import_transaction.subcategory }
          .to(nil)
      end
    end
  end
end
