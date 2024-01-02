# frozen_string_literal: true

RSpec.describe TransactionStatisticsSerializer, type: :serializer do
  let(:serializer) { described_class.new(transactions) }
  let(:transactions) { TransactionSearch.new(profile.transactions, search_params) }
  let(:profile) { create(:profile) }
  let(:start_date) { 10.days.ago }
  let(:end_date) { 1.day.ago }
  let(:search_params) { { exclude_debits: true, start_date: start_date, end_date: end_date } }

  before do
    allow(CurrentDateRange).to receive_messages(start_date:, end_date:)
    allow(Current).to receive_messages(profile:)
  end

  describe '.spends' do
    subject { serializer.as_json[:spends] }

    before do
      create(:transaction, profile: profile, transaction_date: 20.days.ago, amount: -2)
      create(:transaction, profile: profile, transaction_date: 2.days.ago, amount: -12)
      create(:transaction, profile: profile, transaction_date: 2.days.ago, amount: 5)
      create(:transaction, profile: profile, transaction_date: 1.day.from_now, amount: -3)
    end

    it { is_expected.to eq(-12) }
  end

  describe '.money_in' do
    subject { serializer.as_json[:money_in] }

    before do
      create(:transaction, profile: profile, transaction_date: 20.days.ago, amount: -2)
      create(:transaction, profile: profile, transaction_date: 2.days.ago, amount: -12)
      create(:transaction, profile: profile, transaction_date: 2.days.ago, amount: 5)
      create(:transaction, profile: profile, transaction_date: 1.day.from_now, amount: -3)
    end

    it { is_expected.to eq 5 }
  end

  describe '.start_balance' do
    subject { serializer.as_json[:start_balance] }

    context 'when there are no finished reconciliations prior to the period' do
      before do
        create(:transaction, profile: profile, transaction_date: 12.days.ago, amount: 15)
        create(:transaction, profile: profile, transaction_date: 11.days.ago, amount: -3)
        create(:transaction, profile: profile, transaction_date: 10.days.ago, amount: 8)
        create(:transaction, profile: profile, transaction_date: 9.days.ago, amount: 20)
      end

      it { is_expected.to eq 12 }
    end

    context 'when there is a prior finished reconciliation prior to the period' do
      before do
        create(:reconciliation, :finished, profile: profile, date: 12.days.ago, final_balance_amount: 15)
        create(:reconciliation, :finished, profile: profile, date: 5.days.ago, final_balance_amount: 20)
      end

      context 'and there are no transactions between the reconciliation date and the start of the period' do
        before do
          create(:transaction, profile: profile, transaction_date: 12.days.ago, amount: 3)
          create(:transaction, profile: profile, transaction_date: 10.days.ago, amount: -5)
        end

        it { is_expected.to eq 15 }
      end

      context 'and there are some transactions between the reconciliation date and the start of the period' do
        before do
          create(:transaction, profile: profile, transaction_date: 12.days.ago, amount: 3)
          create(:transaction, profile: profile, transaction_date: 11.days.ago, amount: -4)
          create(:transaction, profile: profile, transaction_date: 10.days.ago, amount: -5)
        end

        it { is_expected.to eq 11 }
      end
    end
  end

  describe '.end_balance' do
    subject { serializer.as_json[:end_balance] }

    before { allow(serializer).to receive(:start_balance).and_return(9.99) }

    context 'when there are no transactions in the period' do
      it { is_expected.to eq 9.99 }
    end

    context 'when there are transactions in the period' do
      before do
        create(:transaction, profile: profile, transaction_date: 2.days.ago, amount: 5)
        create(:transaction, profile: profile, transaction_date: 2.days.ago, amount: -2)
      end

      it { is_expected.to eq 12.99 }
    end
  end
end
