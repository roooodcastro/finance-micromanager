# frozen_string_literal: true

RSpec.describe Statistics::CategorySummaryQuery, type: :query do
  describe 'results' do
    subject(:results) { described_class.run(profile_id:, category_ids:, start_date:, end_date:) }

    let(:profile) { create(:profile) }
    let(:profile_id) { profile.id }
    let(:start_date) { nil }
    let(:end_date) { nil }
    let(:category_ids) { nil }

    let!(:category_a) { create(:category, profile: profile, name: 'Cat A') }
    let!(:category_b) { create(:category, profile: profile, name: 'Cat B') }
    let!(:category_c) { create(:category, profile: profile, name: 'Cat C') }

    before do
      create(:transaction, category: category_a, amount: -2, transaction_date: 3.days.ago)
      create(:transaction, category: category_a, amount: -5, transaction_date: 1.day.ago)

      create(:transaction, category: category_b, amount: 9, transaction_date: 1.day.ago)
      create(:transaction, category: category_b, amount: 4, transaction_date: 1.day.from_now)

      create(:transaction, category: category_c, amount: -1, transaction_date: 1.day.from_now)
      create(:transaction, category: category_c, amount: 2, transaction_date: 3.days.from_now)
    end

    context 'when only profile_id is provided' do
      it 'returns all results' do
        expect(results.size).to eq 3
        expect(results[0]).to be_an_instance_of(Statistics::CategorySummary)

        expect(results[0].debit_sum).to eq(-7)
        expect(results[0].credit_sum).to eq(0)

        expect(results[1].debit_sum).to eq(0)
        expect(results[1].credit_sum).to eq(13)

        expect(results[2].debit_sum).to eq(-1)
        expect(results[2].credit_sum).to eq(2)
      end
    end

    context 'when category ids are provided' do
      let(:category_ids) { [category_a.id, category_b.id] }

      it 'returns filtered results' do
        expect(results.size).to eq 2

        expect(results[0].debit_sum).to eq(-7)
        expect(results[0].credit_sum).to eq(0)

        expect(results[1].debit_sum).to eq(0)
        expect(results[1].credit_sum).to eq(13)
      end
    end

    context 'when start date is provided' do
      let(:start_date) { 2.days.ago }

      it 'returns filtered results' do
        expect(results.size).to eq 3

        expect(results[0].debit_sum).to eq(-5)
        expect(results[0].credit_sum).to eq(0)

        expect(results[1].debit_sum).to eq(0)
        expect(results[1].credit_sum).to eq(13)

        expect(results[2].debit_sum).to eq(-1)
        expect(results[2].credit_sum).to eq(2)
      end
    end

    context 'when end date is provided' do
      let(:end_date) { 2.days.from_now }

      it 'returns filtered results' do
        expect(results.size).to eq 3

        expect(results[0].debit_sum).to eq(-7)
        expect(results[0].credit_sum).to eq(0)

        expect(results[1].debit_sum).to eq(0)
        expect(results[1].credit_sum).to eq(13)

        expect(results[2].debit_sum).to eq(-1)
        expect(results[2].credit_sum).to eq(0)
      end
    end

    context 'when both start and end dates are provided' do
      let(:start_date) { 2.days.ago }
      let(:end_date) { 2.days.from_now }

      it 'returns filtered results' do
        expect(results.size).to eq 3

        expect(results[0].debit_sum).to eq(-5)
        expect(results[0].credit_sum).to eq(0)

        expect(results[1].debit_sum).to eq(0)
        expect(results[1].credit_sum).to eq(13)

        expect(results[2].debit_sum).to eq(-1)
        expect(results[2].credit_sum).to eq(0)
      end
    end

    context 'when all parameters are provided' do
      let(:start_date) { 2.days.ago }
      let(:end_date) { 2.days.from_now }
      let(:category_ids) { [category_a.id, category_c.id] }

      it 'returns filtered results' do
        expect(results.size).to eq 2

        expect(results[0].debit_sum).to eq(-5)
        expect(results[0].credit_sum).to eq(0)

        expect(results[1].debit_sum).to eq(-1)
        expect(results[1].credit_sum).to eq(0)
      end
    end
  end
end
