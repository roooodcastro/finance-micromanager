# frozen_string_literal: true

RSpec.describe Transaction do
  describe '#process_amount_type' do
    subject do
      transaction.valid?
      transaction.amount_cents
    end

    let(:transaction) { build(:transaction, amount:) }
    let(:amount) { 9.99 }

    before { transaction.amount_type = amount_type }

    context 'when no amount_type is specified' do
      let(:amount_type) { nil }

      it { is_expected.to eq(999) }
    end

    context 'when amount_type is debit' do
      let(:amount_type) { 'debit' }

      context 'and amount is already negative' do
        let(:amount) { -9.99 }

        it { is_expected.to eq(-999) }
      end

      context 'and amount is positive' do
        let(:amount) { 9.99 }

        it { is_expected.to eq(-999) }
      end
    end

    context 'when amount_type is credit' do
      let(:amount_type) { 'credit' }

      context 'and amount is negative' do
        let(:amount) { -9.99 }

        it { is_expected.to eq(999) }
      end

      context 'and amount is already positive' do
        let(:amount) { 9.99 }

        it { is_expected.to eq(999) }
      end
    end
  end
end
