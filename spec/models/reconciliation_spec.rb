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

      it 'cannot change anything' do
        reconciliation.difference_amount = 1.5

        expect(errors).to be_present
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
end