# frozen_string_literal: true

RSpec.describe TransactionImports::ImportTransaction do
  describe '#currency' do
    subject { import_transaction.currency }

    let(:profile) { create(:profile, currency: :brl) }
    let(:import) { create(:import, profile:) }

    context 'when the profile has a currency' do
      let(:import_transaction) { described_class.new(import:) }

      it { is_expected.to eq('brl') }
    end

    context 'when the profile is empty' do
      let(:import_transaction) { described_class.new }

      it { is_expected.to eq('eur') }
    end
  end
end
