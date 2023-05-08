# frozen_string_literal: true

RSpec.describe Importer::PTSB, type: :service do
  let(:importer) { described_class.new(file_name) }
  let(:file_name) { 'spec/fixtures/importer/ptsb.xls' }

  describe '#parse' do
    subject { importer.parse }

    let(:expected_transactions) do
      [
        ['CNC TESCO STORES 03/05 1', 'CNC TESCO STORES', Date.parse('2023-05-03'), -15.25],
        ['CNC MCDONALDS 70 02/05 1', 'CNC MCDONALDS', Date.parse('2023-05-02'), -8.95],
        ['CNC TESCO STORES 02/05 2', 'CNC TESCO STORES', Date.parse('2023-05-02'), -2.0],
        ['DD TEST DEBIT', 'DD TEST DEBIT', Date.parse('2023-05-03'), -12.34],
        ['Apr Cash Earned', 'Apr Cash Earned', Date.parse('2023-05-02'), 5.00],
        ['PTSB VISA         123456', 'PTSB VISA', Date.parse('2023-04-24'), -2.0]
      ]
    end

    it { is_expected.to eq expected_transactions }
  end
end
