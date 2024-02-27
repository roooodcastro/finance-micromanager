# frozen_string_literal: true

RSpec.describe Importer::N26, type: :service do
  let(:importer) { described_class.new(import) }
  let(:import) { create(:import, :n26) }

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
