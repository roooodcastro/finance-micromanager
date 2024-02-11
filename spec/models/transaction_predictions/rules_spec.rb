# frozen_string_literal: true

RSpec.describe TransactionPredictions::Rules do
  let(:rules) { described_class.new(rules_json.to_json) }

  describe '.valid?' do
    subject(:valid?) { rules.valid? }

    context 'when json_rules is not valid JSON' do
      let(:rules_json) do
        {
          conditions: [],
          actions:    []
        }
      end

      it { is_expected.to be(false) }
    end

    context 'when json_rules is valid' do
      let(:rules_json) do
        {
          conditions: [
            {
              operator: :contains,
              column:   'name',
              value:    'Tesco'
            }
          ],
          actions:    [
            {
              column: 'category_id',
              value:  '047cf511-256c-45ca-a0d6-e8b4d589742c'
            }
          ]
        }
      end

      it { is_expected.to be(true) }
    end
  end
end
