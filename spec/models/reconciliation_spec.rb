# frozen_string_literal: true

RSpec.describe Reconciliation do
  let(:reconciliation) { build(:reconciliation) }

  describe 'Basic factory' do
    subject { reconciliation }

    it { is_expected.to be_valid }
  end

  describe '#validate_no_in_progress_reconciliations' do
    subject do
      reconciliation.valid?
      reconciliation.errors[:base]
    end

    let(:profile) { create(:profile) }
    let(:reconciliation) { build(:reconciliation, profile: profile, date: Date.current) }

    context 'when there is no other reconciliation' do
      it { is_expected.to be_empty }
    end

    context 'when there is another "in progress" reconciliation, but for another profile' do
      before { create(:reconciliation, :in_progress) }

      it { is_expected.to be_empty }
    end

    context 'when there is another "finished" reconciliation' do
      before { create(:reconciliation, :finished, profile:) }

      it { is_expected.to be_empty }
    end

    context 'when there is another "cancelled" reconciliation' do
      before { create(:reconciliation, :cancelled, profile:) }

      it { is_expected.to be_empty }
    end

    context 'when there is another "in progress" reconciliation' do
      before { create(:reconciliation, :in_progress, profile:) }

      it { is_expected.to be_present }
    end
  end

  describe '#validate_date_not_before_other_reconciliation' do
    subject do
      reconciliation.valid?
      reconciliation.errors[:date]
    end

    let(:profile) { create(:profile) }
    let(:reconciliation) { build(:reconciliation, profile: profile, date: 7.days.ago) }

    context 'when there is no other reconciliation' do
      it { is_expected.to be_empty }
    end

    context 'when there is a newer "cancelled" reconciliation' do
      before { create(:reconciliation, :cancelled, profile: profile, date: 1.day.ago) }

      it { is_expected.to be_empty }
    end

    context 'when there is a newer "finished" reconciliation, but for another profile' do
      before { create(:reconciliation, :finished, date: 1.day.ago) }

      it { is_expected.to be_empty }
    end

    context 'when there is a newer "finished" reconciliation' do
      before { create(:reconciliation, :finished, profile: profile, date: 1.day.ago) }

      it { is_expected.to be_present }
    end

    context 'when there is a "finished" reconciliation for the same day' do
      before { create(:reconciliation, :finished, profile: profile, date: 7.days.ago) }

      it { is_expected.to be_present }
    end
  end

  describe '#validate_no_changes_after_finished' do
    subject(:errors) do
      reconciliation.valid?
      reconciliation.errors[:base]
    end

    let(:reconciliation) { create(:reconciliation) }

    context 'when reconciliation is not finished' do
      it 'can still change other attributes' do
        reconciliation.difference_amount = 1.5
        reconciliation.date              = 1.day.from_now

        expect(errors).to be_empty
      end
    end

    context 'when reconciliation is transitioning to finished status' do
      it 'can still change other attributes' do
        reconciliation.difference_amount = 1.5
        reconciliation.date              = 1.day.from_now
        reconciliation.status            = :finished

        expect(errors).to be_empty
      end
    end

    context 'when reconciliation is already finished' do
      let(:reconciliation) { create(:reconciliation, :finished) }

      it 'cannot change status to in_progress' do
        reconciliation.status = :in_progress

        expect(errors).to be_present
      end

      it 'cannot change status to cancelled' do
        reconciliation.status = :cancelled

        expect(errors).to be_present
      end

      it 'cannot change other attributes' do
        reconciliation.date = 1.day.from_now

        expect(errors).to be_present
      end
    end
  end

  describe '#validate_no_changes_after_cancelled' do
    subject(:errors) do
      reconciliation.valid?
      reconciliation.errors[:base]
    end

    let(:reconciliation) { create(:reconciliation) }

    context 'when reconciliation is not cancelled' do
      it 'can still change other attributes' do
        reconciliation.difference_amount = 1.5
        reconciliation.date              = 1.day.from_now

        expect(errors).to be_empty
      end
    end

    context 'when reconciliation is transitioning to cancelled status' do
      it 'can still change other attributes' do
        reconciliation.difference_amount = 1.5
        reconciliation.date              = 1.day.from_now
        reconciliation.status            = :cancelled

        expect(errors).to be_empty
      end
    end

    context 'when reconciliation is already cancelled' do
      let(:reconciliation) { create(:reconciliation, :cancelled) }

      it 'cannot change status to in_progress' do
        reconciliation.status = :in_progress

        expect(errors).to be_present
      end

      it 'cannot change status to finished' do
        reconciliation.status = :finished

        expect(errors).to be_present
      end

      it 'cannot change other attributes' do
        reconciliation.date = 1.day.from_now

        expect(errors).to be_present
      end
    end
  end

  describe '#validate_finish_date_in_future' do
    subject do
      reconciliation.valid?
      reconciliation.errors[:date]
    end

    let(:reconciliation) { build(:reconciliation, :finished, date:) }

    context 'when date is in the future but status is not finished' do
      let(:reconciliation) { build(:reconciliation, :in_progress, date:) }
      let(:date) { 1.day.from_now }

      it { is_expected.to be_empty }
    end

    context 'when date is today and status is finished' do
      let(:date) { Date.current }

      it { is_expected.to be_empty }
    end

    context 'when date is in the past and status is finished' do
      let(:date) { 1.day.ago }

      it { is_expected.to be_empty }
    end

    context 'when date is in the future and status is finished' do
      let(:date) { 1.day.from_now }

      it { is_expected.to be_present }
    end
  end

  describe '#validate_no_transaction_without_wallets' do
    subject do
      reconciliation.valid?
      reconciliation.errors[:base]
    end

    let(:profile) { create(:profile) }
    let(:reconciliation) { build(:reconciliation, :in_progress, profile: profile, date: 1.day.ago) }

    context 'when reconciliation is not finished' do
      before { create(:transaction, profile: profile, transaction_date: 2.days.ago, wallet: nil) }

      it { is_expected.to be_empty }
    end

    context 'when reconciliation is being finished' do
      let(:reconciliation) { build(:reconciliation, :finished, profile: profile, date: 1.day.ago) }

      context 'and all transactions have wallets' do
        let(:wallet) { create(:wallet, profile:) }

        before { create(:transaction, profile: profile, transaction_date: 2.days.ago, wallet: wallet) }

        it { is_expected.to be_empty }
      end

      context 'and a transaction does not have a wallet' do
        before { create(:transaction, profile: profile, transaction_date: 2.days.ago, wallet: nil) }

        it { is_expected.to be_present }
      end
    end
  end

  describe '.currency' do
    subject(:currency) { reconciliation.currency }

    let(:reconciliation) { build(:reconciliation, profile:) }

    context 'when profile association is blank' do
      let(:profile) { nil }

      it 'defaults to the system default currency' do
        expect(currency).to eq(Money.default_currency)
      end
    end

    context 'when profile association is present' do
      let(:profile) { create(:profile, currency: :cad) }

      it 'returns the profile currency' do
        expect(currency).to eq(Money::Currency.find(:cad))
      end
    end
  end

  describe '.transactions' do
    subject(:transactions) { reconciliation.transactions }

    let(:profile) { create(:profile) }
    let(:wallet) { create(:wallet, profile:) }
    let(:reconciliation) { build(:reconciliation, profile: profile, date: 1.day.ago) }

    let!(:older_transaction) { create(:transaction, profile: profile, transaction_date: 4.days.ago) }
    let!(:start_limit_transaction) { create(:transaction, profile: profile, transaction_date: 3.days.ago) }
    let!(:mid_transaction) { create(:transaction, profile: profile, transaction_date: 2.days.ago) }
    let!(:end_limit_transaction) { create(:transaction, profile: profile, transaction_date: 1.day.ago) }

    before { create(:transaction, profile: profile, transaction_date: Date.current) }

    context 'when there are no previous finished reconciliations' do
      it 'returns all relevant transactions' do
        expect(transactions)
          .to contain_exactly(older_transaction, start_limit_transaction, mid_transaction, end_limit_transaction)
      end
    end

    context 'when there is a previous finished reconciliation' do
      before do
        create(:reconciliation, :finished, profile: profile, date: 3.days.ago)
        profile.reload
      end

      it { is_expected.to contain_exactly(mid_transaction, end_limit_transaction) }
    end
  end
end
