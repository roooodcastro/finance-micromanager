# frozen_string_literal: true

RSpec.describe TransactionPrediction do
  let(:transaction_prediction) { build(:transaction_prediction) }

  describe '#rules' do
    subject { transaction_prediction.rules }

    it { is_expected.to be_an_instance_of(TransactionPredictions::Rules) }
  end
end
