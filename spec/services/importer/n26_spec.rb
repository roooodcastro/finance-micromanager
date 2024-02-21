# frozen_string_literal: true

RSpec.describe Importer::N26, type: :service do
  let(:importer) { described_class.new(file_name, wallet) }
  let(:file_name) { 'spec/fixtures/importer/n26.csv' }
  let(:wallet) { create(:wallet) }

  describe '#parse' do
    subject { importer.parse }

    let(:expected_transactions) do
      [
        ['NETFLIX.COM', 'NETFLIX.COM', Date.parse('2023-04-07'), -20],
        ['From Test Space to Main Wallet', 'From Test Space to Main Wallet', Date.parse('2023-04-12'), 100],
        ['WWW.ALIEXPRESS.COM', 'WWW.ALIEXPRESS.COM', Date.parse('2023-04-13'), -9.99]
      ]
    end

    it { is_expected.to eq expected_transactions }
  end
end
