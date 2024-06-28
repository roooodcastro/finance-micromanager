# frozen_string_literal: true

RSpec.describe Importer::PTSB, type: :service do
  let(:importer) { described_class.new(import) }
  let(:import) { create(:import, :ptsb) }

  describe '#parse' do
    subject { importer.parse }

    around do |example|
      travel_to(Time.zone.parse('2023-12-31')) { example.run }
    end

    let(:expected_transactions) do
      [
        {
          id:               'ac194796-dc5a-558b-9945-10301efb798c',
          import_name:      'CNC TESCO STORES 03/05 1',
          transaction_name: 'CNC TESCO STORES',
          transaction_date: Date.parse('2023-05-03'),
          amount:           -15.25
        },
        {
          id:               '4361b712-7cdc-594f-bf06-e8e079b4df35',
          import_name:      'CNC MCDONALDS 70 02/05 1',
          transaction_name: 'CNC MCDONALDS',
          transaction_date: Date.parse('2023-05-02'),
          amount:           -8.95
        },
        {
          id:               '11649b54-c3e8-5192-a749-2d5a78829e66',
          import_name:      'CNC TESCO STORES 02/05 2',
          transaction_name: 'CNC TESCO STORES',
          transaction_date: Date.parse('2023-05-02'),
          amount:           -2.0
        },
        {
          id:               '07efaa54-ea21-52db-9923-17673b85899a',
          import_name:      'DD TEST DEBIT',
          transaction_name: 'DD TEST DEBIT',
          transaction_date: Date.parse('2023-05-03'),
          amount:           -12.34
        },
        {
          id:               '9ee8104a-168e-5ee8-8b83-6d22cd4a9e71',
          import_name:      'Apr Cash Earned',
          transaction_name: 'Apr Cash Earned',
          transaction_date: Date.parse('2023-05-02'),
          amount:           5.00
        },
        {
          id:               '34ec48f8-a024-516a-be1c-bce788593242',
          import_name:      'PTSB VISA         123456',
          transaction_name: 'PTSB VISA',
          transaction_date: Date.parse('2023-04-24'),
          amount:           -2.0
        }
      ]
    end

    it { is_expected.to eq expected_transactions }
  end
end
