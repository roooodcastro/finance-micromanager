# frozen_string_literal: true

RSpec.describe TransactionAutomation do
  let(:transaction_automation) { build(:transaction_automation) }

  describe '.bump_scheduled_date!', :travel_to_now do
    subject(:bump_scheduled_date!) { transaction_automation.bump_scheduled_date! }

    let(:transaction_automation) { create(:transaction_automation, schedule_type:, schedule_interval:) }
    let(:schedule_type) { :month }
    let(:schedule_interval) { 1 }

    context 'when schedule_type is month' do
      let(:schedule_type) { :month }
      let(:schedule_interval) { 2 }

      it 'changes scheduled_date accordingly' do
        expect { bump_scheduled_date! }
          .to change { transaction_automation.reload.scheduled_date }.to(2.months.from_now.to_date)
      end
    end

    context 'when schedule_type is week' do
      let(:schedule_type) { :week }
      let(:schedule_interval) { 3 }

      it 'changes scheduled_date accordingly' do
        expect { bump_scheduled_date! }
          .to change { transaction_automation.reload.scheduled_date }.to(3.weeks.from_now.to_date)
      end
    end

    context 'when schedule_type is day' do
      let(:schedule_type) { :day }
      let(:schedule_interval) { 1 }

      it 'changes scheduled_date accordingly' do
        expect { bump_scheduled_date! }
          .to change { transaction_automation.reload.scheduled_date }.to(1.day.from_now.to_date)
      end
    end

    context 'when schedule_type is nil' do
      it 'does not change scheduled_date' do
        transaction_automation.schedule_type = nil
        expect { bump_scheduled_date! }.not_to change { transaction_automation.scheduled_date }
      end
    end
  end
end
