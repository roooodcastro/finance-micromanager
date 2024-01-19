# frozen_string_literal: true

RSpec.describe TransactionAutomation do
  let(:transaction_automation) { build(:transaction_automation) }

  describe '.bump_next_schedule_date!', :travel_to_now do
    subject(:bump_next_schedule_date!) { transaction_automation.bump_next_schedule_date! }

    let(:transaction_automation) { create(:transaction_automation, schedule_type:, schedule_interval:) }
    let(:schedule_type) { :month }
    let(:schedule_interval) { 1 }

    context 'when schedule_type is month' do
      let(:schedule_type) { :month }
      let(:schedule_interval) { 2 }

      it 'changes next_schedule_date accordingly' do
        expect { bump_next_schedule_date! }
          .to change { transaction_automation.reload.next_schedule_date }.to(2.months.from_now.to_date)
      end
    end

    context 'when schedule_type is week' do
      let(:schedule_type) { :week }
      let(:schedule_interval) { 3 }

      it 'changes next_schedule_date accordingly' do
        expect { bump_next_schedule_date! }
          .to change { transaction_automation.reload.next_schedule_date }.to(3.weeks.from_now.to_date)
      end
    end

    context 'when schedule_type is day' do
      let(:schedule_type) { :day }
      let(:schedule_interval) { 1 }

      it 'changes next_schedule_date accordingly' do
        expect { bump_next_schedule_date! }
          .to change { transaction_automation.reload.next_schedule_date }.to(1.day.from_now.to_date)
      end
    end

    context 'when schedule_type is nil' do
      it 'does not change next_schedule_date' do
        transaction_automation.schedule_type = nil
        expect { bump_next_schedule_date! }.not_to change { transaction_automation.next_schedule_date }
      end
    end
  end
end
