# frozen_string_literal: true

RSpec.describe TransactionAutomations::ProcessTransactionAutomations do
  let(:service) { described_class.new(date) }

  let(:date) { Date.current }
  let(:scheduled_date) { date }
  let(:profile) { create(:profile) }

  describe '.call' do
    subject(:service_call) { service.call }

    context 'when there are no automations', :travel_to_now do
      it 'does not create a transaction' do
        expect { service_call }.not_to change { Transaction.count }
      end
    end

    context 'when there is an active automation but the scheduled_date is in the future', :travel_to_now do
      before { create(:transaction_automation, profile: profile, scheduled_date: 2.days.from_now) }

      it 'does not create a transaction' do
        expect { service_call }.not_to change { Transaction.count }
      end
    end

    context 'when there is an active automation and scheduled_date is in the past', :travel_to_now do
      let(:category) { create(:category, profile:) }

      let!(:transaction_automation) do
        create(:transaction_automation,
               profile:              profile,
               scheduled_date:       2.days.ago,
               schedule_type:        :day,
               schedule_interval:    5,
               schedule_day:         nil,
               transaction_name:     'Service Test',
               transaction_amount:   5.49,
               transaction_category: category)
      end

      it 'creates a new transaction with the same data as the automation and bumps scheduled_date' do
        expect { service_call }
          .to change { Transaction.count }
          .by(1)
          .and change { transaction_automation.reload.scheduled_date }
          .to(3.days.from_now.to_date)

        new_transaction = Transaction.last
        expect(new_transaction.name).to eq 'Service Test'
        expect(new_transaction.transaction_date).to eq 2.days.ago.to_date
        expect(new_transaction.amount.to_f).to eq(5.49)
        expect(new_transaction.category).to eq category
        expect(new_transaction.profile).to eq profile
      end
    end

    context 'when there is an active automation with the same scheduled_date', :travel_to_now do
      let!(:transaction_automation) do
        create(:transaction_automation,
               profile:           profile,
               scheduled_date:    date,
               schedule_type:     :week,
               schedule_day:      2, # Tuesday
               schedule_interval: 1,
               weekend_rule:      nil)
      end

      it 'creates a new transaction with the same data as the automation and bumps scheduled_date' do
        expect { service_call }
          .to change { Transaction.count }
          .by(1)
          .and change { transaction_automation.reload.scheduled_date }
          .to(7.days.from_now.to_date.beginning_of_week(:tuesday))
      end
    end

    context 'when there is a monthly automation with the day set to 31 but schedule_date is the 30th' do
      let!(:transaction_automation) do
        create(
          :transaction_automation,
          profile:           profile,
          scheduled_date:    Date.parse('2025-06-30'),
          schedule_type:     :month,
          schedule_interval: 1,
          schedule_day:      31
        )
      end

      around { |example| travel_to(Date.parse('2025-06-30')) { example.run } }

      it 'creates a new transaction and bumps scheduled_date to the 31th of next month' do
        expect { service_call }
          .to change { Transaction.count }
          .by(1)
          .and change { transaction_automation.reload.scheduled_date }
          .to(Date.parse('2025-07-31'))
      end
    end

    context 'when there is a monthly automation with the day set to 31 but next month has 30 days' do
      let!(:transaction_automation) do
        create(
          :transaction_automation,
          profile:           profile,
          scheduled_date:    Date.parse('2025-08-31'),
          schedule_type:     :month,
          schedule_interval: 1,
          schedule_day:      31
        )
      end

      around { |example| travel_to(Date.parse('2025-08-31')) { example.run } }

      it 'creates a new transaction and bumps scheduled_date to the 30th of next month' do
        expect { service_call }
          .to change { Transaction.count }
          .by(1)
          .and change { transaction_automation.reload.scheduled_date }
          .to(Date.parse('2025-09-30'))
      end
    end

    context 'when there is a disabled automation with the same scheduled_date', :travel_to_now do
      let!(:transaction_automation) do
        create(:transaction_automation, :disabled, profile: profile, scheduled_date: date)
      end

      it 'does not create a transaction but does bump the date' do
        expect { service_call }
          .to not_change { Transaction.count }
          .and change { transaction_automation.reload.scheduled_date }
          .to(1.month.from_now.to_date)
      end
    end

    context 'when there is a monthly automation with create_at_start_of_period but it is not the start of period' do
      before do
        create(
          :transaction_automation,
          profile:                   profile,
          scheduled_date:            '2025-07-13',
          create_at_start_of_period: true,
          schedule_day:              13
        )
      end

      around { |example| travel_to(Date.parse('2025-06-30')) { example.run } }

      it 'does not create a transaction' do
        expect { service_call }.not_to change { Transaction.count }
      end
    end

    context 'when there is a monthly automation with create_at_start_of_period and it is past the start of period' do
      let!(:transaction_automation) do
        create(
          :transaction_automation,
          profile:                   profile,
          scheduled_date:            '2025-07-13',
          create_at_start_of_period: true,
          schedule_day:              13
        )
      end

      around { |example| travel_to(Date.parse('2025-07-01')) { example.run } }

      it 'creates a new transaction with the same data as the automation and bumps scheduled_date' do
        expect { service_call }
          .to change { Transaction.count }
          .by(1)
          .and change { transaction_automation.reload.scheduled_date }
          .to(Date.parse('2025-08-13'))

        new_transaction = Transaction.last
        expect(new_transaction.transaction_date).to eq Date.parse('2025-07-13')
        expect(new_transaction.profile).to eq profile
      end
    end

    context 'when there is a weekly automation with create_at_start_of_period but it is not the start of period' do
      before do
        create(
          :transaction_automation,
          :schedule_type_week,
          profile:                   profile,
          scheduled_date:            '2025-07-10',
          create_at_start_of_period: true,
          schedule_day:              4
        )
      end

      around { |example| travel_to(Date.parse('2025-07-05')) { example.run } }

      it 'does not create a transaction' do
        expect { service_call }.not_to change { Transaction.count }
      end
    end

    context 'when there is a weekly automation with create_at_start_of_period and it is past the start of period' do
      let!(:transaction_automation) do
        create(
          :transaction_automation,
          :schedule_type_week,
          profile:                   profile,
          scheduled_date:            '2025-07-10',
          create_at_start_of_period: true,
          schedule_day:              4
        )
      end

      around { |example| travel_to(Date.parse('2025-07-06')) { example.run } }

      it 'creates a new transaction with the same data as the automation and bumps scheduled_date' do
        expect { service_call }
          .to change { Transaction.count }
          .by(1)
          .and change { transaction_automation.reload.scheduled_date }
          .to(Date.parse('2025-07-17'))

        new_transaction = Transaction.last
        expect(new_transaction.transaction_date).to eq Date.parse('2025-07-10')
        expect(new_transaction.profile).to eq profile
      end
    end

    context 'when there is a custom automation with create_at_start_of_period but it is not the start of period' do
      before do
        create(
          :transaction_automation,
          :schedule_type_last_weekday_of_month,
          profile:                   profile,
          scheduled_date:            '2025-07-13',
          create_at_start_of_period: true
        )
      end

      around { |example| travel_to(Date.parse('2025-06-30')) { example.run } }

      it 'does not create a transaction' do
        expect { service_call }.not_to change { Transaction.count }
      end
    end

    context 'when there is a custom automation with create_at_start_of_period and it is past the start of period' do
      let!(:transaction_automation) do
        create(
          :transaction_automation,
          :schedule_type_last_weekday_of_month,
          profile:                   profile,
          scheduled_date:            '2025-08-29',
          create_at_start_of_period: true
        )
      end

      around { |example| travel_to(Date.parse('2025-08-01')) { example.run } }

      it 'creates a new transaction with the same data as the automation and bumps scheduled_date' do
        expect { service_call }
          .to change { Transaction.count }
          .by(1)
          .and change { transaction_automation.reload.scheduled_date }
          .to(Date.parse('2025-09-30'))

        new_transaction = Transaction.last
        expect(new_transaction.transaction_date).to eq Date.parse('2025-08-29')
        expect(new_transaction.profile).to eq profile
      end
    end
  end
end
