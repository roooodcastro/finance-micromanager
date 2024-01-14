# frozen_string_literal: true

RSpec.describe TransactionAutomations::ProcessTransactionAutomations, :travel_to_now do
  let(:service) { described_class.new(date) }

  let(:date) { Date.current }
  let(:next_schedule_date) { date }
  let(:profile) { create(:profile) }

  describe '.call' do
    subject(:service_call) { service.call }

    context 'when there are no automations' do
      it 'does not create a transaction' do
        expect { service_call }.not_to change { Transaction.count }
      end
    end

    context 'when there is an active automation but the next_schedule_date is in the future' do
      before { create(:transaction_automation, profile: profile, next_schedule_date: 2.days.from_now) }

      it 'does not create a transaction' do
        expect { service_call }.not_to change { Transaction.count }
      end
    end

    context 'when there is an active automation and next_schedule_date is in the past' do
      let(:category) { create(:category, profile:) }

      let!(:transaction_automation) do
        create(:transaction_automation,
               profile:              profile,
               next_schedule_date:   2.days.ago,
               schedule_type:        :day,
               schedule_interval:    5,
               transaction_name:     'Service Test',
               transaction_amount:   5.49,
               transaction_category: category)
      end

      it 'creates a new transaction with the same data as the automation and bumps next_schedule_date' do
        expect { service_call }
          .to change { Transaction.count }
          .by(1)
          .and change { transaction_automation.reload.next_schedule_date }
          .to(3.days.from_now.to_date)

        new_transaction = Transaction.last
        expect(new_transaction.name).to eq 'Service Test'
        expect(new_transaction.transaction_date).to eq 2.days.ago.to_date
        expect(new_transaction.amount.to_f).to eq(5.49)
        expect(new_transaction.category).to eq category
        expect(new_transaction.profile).to eq profile
      end
    end

    context 'when there is an active automation with the same next_schedule_date' do
      let!(:transaction_automation) do
        create(:transaction_automation,
               profile:            profile,
               next_schedule_date: date,
               schedule_type:      :week,
               schedule_interval:  1)
      end

      it 'creates a new transaction with the same data as the automation and bumps next_schedule_date' do
        expect { service_call }
          .to change { Transaction.count }
          .by(1)
          .and change { transaction_automation.reload.next_schedule_date }
          .to(7.days.from_now.to_date)
      end
    end

    context 'when there is a disabled automation with the same next_schedule_date' do
      before { create(:transaction_automation, :disabled, profile: profile, next_schedule_date: date) }

      it 'does not create a transaction' do
        expect { service_call }.not_to change { Transaction.count }
      end
    end
  end
end
