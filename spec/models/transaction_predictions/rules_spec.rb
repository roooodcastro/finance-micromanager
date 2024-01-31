# frozen_string_literal: true

RSpec.describe TransactionPredictions::Rules do
  let(:rules) { described_class.new(rules_json.to_json) }

  describe '.valid?' do
    subject(:valid?) { rules.valid? }

    context 'when json_rules is not valid JSON' do
      
    end
  end
end
