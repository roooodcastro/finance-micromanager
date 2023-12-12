# frozen_string_literal: true

RSpec.describe Reconciliations::FinishReconciliation do
  let(:service) { described_class.new(reconciliation) }

  describe '#self.call' do
    it 'creates a new instance and runs "call"' do
      expect_any_instance_of(described_class).to receive(:call) # rubocop:disable RSpec/AnyInstance
      described_class.call(instance_double(Reconciliation, finished!: true))
    end
  end

  describe '.call' do
    subject(:service_call) { service.call }

    let(:reconciliation) { create(:reconciliation, :in_progress) }

    it 'marks the reconciliation as finished' do
      expect { service_call }.to change { reconciliation.reload.status }.to('finished')
    end
  end
end
