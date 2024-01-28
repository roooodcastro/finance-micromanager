# frozen_string_literal: true

RSpec.describe TransactionAutomation do
  let(:transaction_automation) { build(:transaction_automation) }

  describe '.bump_scheduled_date!', :travel_to_now do
    subject(:bump_scheduled_date!) { transaction_automation.bump_scheduled_date! }

    let(:transaction_automation) do
      create(:transaction_automation, schedule_type:, schedule_interval:, scheduled_date:, schedule_custom_rule:)
    end

    let(:schedule_type) { :month }
    let(:schedule_interval) { 1 }
    let(:scheduled_date) { Date.current }
    let(:schedule_custom_rule) { nil }

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

    context 'when schedule_type is custom' do
      let(:schedule_type) { :custom }
      let(:schedule_custom_rule) { TransactionAutomations::CustomRule::LAST_DAY_OF_MONTH }
      let(:schedule_interval) { nil }
      let(:scheduled_date) { '2024-02-29' }

      it 'changes scheduled_date accordingly' do
        expect { bump_scheduled_date! }
          .to change { transaction_automation.reload.scheduled_date }.to(Date.parse('2024-03-31'))
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
