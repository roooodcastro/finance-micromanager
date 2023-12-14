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
end
