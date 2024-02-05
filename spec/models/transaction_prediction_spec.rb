# frozen_string_literal: true

RSpec.describe TransactionPrediction do
  let(:transaction_prediction) { build(:transaction_prediction, rules_json:) }

  describe '#rules' do
    subject { transaction_prediction.rules }

    context 'when rules_json is present' do
      let(:rules_json) { { conditions: [] }.to_json }

      it { is_expected.to be_an_instance_of(TransactionPredictions::Rules) }
    end

    context 'when rules_json is absent' do
      let(:rules_json) { nil }

      it { is_expected.to be_nil }
    end
  end
end
