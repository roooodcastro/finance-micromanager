# frozen_string_literal: true

RSpec.describe TransactionAutomation do
  let(:transaction_automation) { build(:transaction_automation, profile:) }
  let(:profile) { create(:profile) }

  describe 'validate_category_is_enabled' do
    subject(:errors) do
      transaction_automation.valid?
      transaction_automation.errors[:transaction_category_id]
    end

    context 'when creating a transaction automation' do
      let(:transaction_automation) { build(:transaction_automation, profile: profile, transaction_category: category) }

      context 'when the category is nil' do
        let(:category) { nil }

        it { is_expected.to be_empty }
      end

      context 'when the category is enabled' do
        let(:category) { create(:category, :enabled, profile:) }

        it { is_expected.to be_empty }
      end

      context 'when the category is disabled' do
        let(:category) { create(:category, :disabled, profile:) }

        it { is_expected.to eq ['must be enabled'] }
      end
    end

    context 'when updating a transaction automation where the category is not changed' do
      let(:transaction_automation) { create(:transaction_automation, profile: profile, transaction_category: category) }
      let(:category) { create(:category, :enabled, profile:) }

      before { transaction_automation.transaction_name = 'Other name' }

      context 'when the category is enabled' do
        it { is_expected.to be_empty }
      end

      context 'when the category is disabled' do
        before do
          allow(Current).to receive(:user).and_return(profile.user)
          category.disable!
        end

        it { is_expected.to be_empty }
      end
    end

    context 'when updating a transaction automation where the category is changed' do
      let(:transaction_automation) do
        create(:transaction_automation, profile: profile, transaction_category: enabled_category)
      end

      let(:enabled_category) { create(:category, :enabled, profile:) }
      let(:enabled_category2) { create(:category, :enabled, profile:) }
      let(:disabled_category) { create(:category, :disabled, profile:) }

      before { transaction_automation.transaction_category = new_category }

      context 'when the category is nil' do
        let(:new_category) { nil }

        it { is_expected.to be_empty }
      end

      context 'when the category is enabled' do
        let(:new_category) { enabled_category2 }

        it { is_expected.to be_empty }
      end

      context 'when the category is disabled' do
        let(:new_category) { disabled_category }

        it { is_expected.to eq ['must be enabled'] }
      end
    end
  end

  describe 'validate_wallet_is_enabled' do
    subject(:errors) do
      transaction_automation.valid?
      transaction_automation.errors[:transaction_wallet_id]
    end

    context 'when creating a transaction automation' do
      let(:transaction_automation) { build(:transaction_automation, profile: profile, transaction_wallet: wallet) }

      context 'when the wallet is nil' do
        let(:wallet) { nil }

        it { is_expected.to be_empty }
      end

      context 'when the wallet is enabled' do
        let(:wallet) { create(:wallet, :enabled, profile:) }

        it { is_expected.to be_empty }
      end

      context 'when the category is disabled' do
        let(:wallet) { create(:wallet, :disabled, profile:) }

        it { is_expected.to eq ['must be enabled'] }
      end
    end

    context 'when updating a transaction automation where the wallet is not changed' do
      let(:transaction_automation) { create(:transaction_automation, profile: profile, transaction_wallet: wallet) }
      let(:wallet) { create(:wallet, :enabled, profile:) }

      before { transaction_automation.transaction_name = 'Other name' }

      context 'when the wallet is enabled' do
        it { is_expected.to be_empty }
      end

      context 'when the wallet is disabled' do
        before do
          allow(Current).to receive(:user).and_return(profile.user)
          wallet.disable!
        end

        it { is_expected.to be_empty }
      end
    end

    context 'when updating a transaction automation where the wallet is changed' do
      let(:transaction_automation) do
        create(:transaction_automation, profile: profile, transaction_wallet: enabled_wallet)
      end

      let(:enabled_wallet) { create(:wallet, :enabled, profile:) }
      let(:enabled_wallet2) { create(:wallet, :enabled, profile:) }
      let(:disabled_wallet) { create(:wallet, :disabled, profile:) }

      before { transaction_automation.transaction_wallet = new_wallet }

      context 'when the wallet is nil' do
        let(:new_wallet) { nil }

        it { is_expected.to be_empty }
      end

      context 'when the wallet is enabled' do
        let(:new_wallet) { enabled_wallet2 }

        it { is_expected.to be_empty }
      end

      context 'when the wallet is disabled' do
        let(:new_wallet) { disabled_wallet }

        it { is_expected.to eq ['must be enabled'] }
      end
    end
  end

  describe '.bump_scheduled_date!', :travel_to_now do
    subject(:bump_scheduled_date!) { transaction_automation.bump_scheduled_date! }

    let(:transaction_automation) do
      create(
        :transaction_automation,
        schedule_type:,
        schedule_interval:,
        scheduled_date:,
        schedule_custom_rule:,
        schedule_day:
      )
    end

    let(:schedule_type) { :month }
    let(:schedule_interval) { 1 }
    let(:scheduled_date) { Date.current }
    let(:schedule_custom_rule) { nil }
    let(:schedule_day) { 1 }

    context 'when schedule_type is month but schedule_day is nil' do
      let(:schedule_type) { :month }
      let(:schedule_interval) { 2 }
      let(:schedule_day) { 1 }

      it 'does not change the scheduled_date' do
        transaction_automation.schedule_day = nil
        expect { transaction_automation.bump_scheduled_date! }
          .not_to change { transaction_automation.scheduled_date }
      end
    end

    context 'when schedule_type is month' do
      let(:schedule_type) { :month }
      let(:schedule_interval) { 2 }
      let(:schedule_day) { 11 }

      it 'changes scheduled_date accordingly' do
        expect { bump_scheduled_date! }
          .to change { transaction_automation.scheduled_date }
          .to(2.months.from_now.to_date.change(day: 11))
      end
    end

    context 'when schedule_type is week but schedule_day is nil' do
      let(:schedule_type) { :week }
      let(:schedule_interval) { 2 }
      let(:schedule_day) { 0 }

      it 'does not change the scheduled_date' do
        transaction_automation.schedule_day = nil
        expect { transaction_automation.bump_scheduled_date! }
          .not_to change { transaction_automation.scheduled_date }
      end
    end

    context 'when schedule_type is week' do
      let(:schedule_type) { :week }
      let(:schedule_interval) { 3 }
      let(:schedule_day) { 6 } # Saturday

      it 'changes scheduled_date accordingly' do
        expect { bump_scheduled_date! }
          .to change { transaction_automation.scheduled_date }
          .to(3.weeks.from_now.to_date.beginning_of_week(:saturday))
      end
    end

    context 'when schedule_type is day' do
      let(:schedule_type) { :day }
      let(:schedule_interval) { 3 }
      let(:schedule_day) { nil }

      it 'changes scheduled_date accordingly' do
        expect { bump_scheduled_date! }
          .to change { transaction_automation.scheduled_date }.to(3.days.from_now.to_date)
      end
    end

    context 'when schedule_type is custom' do
      let(:schedule_type) { :custom }
      let(:schedule_custom_rule) { TransactionAutomations::CustomRule::LAST_DAY_OF_MONTH }
      let(:schedule_interval) { nil }
      let(:scheduled_date) { '2024-02-29' }
      let(:schedule_day) { nil }

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

  describe '#next_run_at' do
    subject { transaction_automation.next_run_at }

    let(:transaction_automation) do
      create(
        :transaction_automation,
        profile:,
        scheduled_date:,
        create_at_start_of_period:,
        schedule_type:,
        schedule_day:
      )
    end

    context 'when create_at_start_of_period is false' do
      let(:create_at_start_of_period) { false }
      let(:scheduled_date) { '2025-07-03' }
      let(:schedule_type) { :month }
      let(:schedule_day) { 3 }

      it { is_expected.to eq(Date.parse('2025-07-03')) }
    end

    context 'when create_at_start_of_period is true and schedule type is week' do
      let(:create_at_start_of_period) { true }
      let(:scheduled_date) { '2025-07-10' }
      let(:schedule_type) { :week }
      let(:schedule_day) { 5 } # Friday

      it { is_expected.to eq(Date.parse('2025-07-06')) }
    end

    context 'when create_at_start_of_period is true and schedule type is month' do
      let(:create_at_start_of_period) { true }
      let(:scheduled_date) { '2025-07-25' }
      let(:schedule_type) { :month }
      let(:schedule_day) { 15 }

      it { is_expected.to eq(Date.parse('2025-07-01')) }
    end
  end

  describe '#humanized_schedule' do
    subject { transaction_automation.humanized_schedule }

    let(:transaction_automation) do
      create(
        :transaction_automation,
        profile:,
        schedule_type:,
        schedule_custom_rule:,
        schedule_interval:,
        schedule_day:
      )
    end

    let(:schedule_custom_rule) { nil }
    let(:schedule_interval) { nil }
    let(:schedule_day) { nil }

    context 'when schedule_type is custom' do
      let(:schedule_type) { :custom }
      let(:schedule_custom_rule) { TransactionAutomations::CustomRule::LAST_DAY_OF_MONTH }

      it { is_expected.to eq('Every last day of month') }
    end

    context 'when schedule_type is month' do
      let(:schedule_type) { :month }
      let(:schedule_interval) { 1 }
      let(:schedule_day) { 12 }

      it { is_expected.to eq('Every month on day 12') }
    end

    context 'when schedule_type is week' do
      let(:schedule_type) { :week }
      let(:schedule_interval) { 2 }
      let(:schedule_day) { 4 }

      it { is_expected.to eq('Every 2 weeks on Thursday') }
    end

    context 'when schedule_type is day' do
      let(:schedule_type) { :day }
      let(:schedule_interval) { 15 }

      it { is_expected.to eq('Every 15 days') }
    end
  end

  describe '#humanized_next_run' do
    subject { transaction_automation.humanized_next_run }

    let(:transaction_automation) do
      create(:transaction_automation, profile:, scheduled_date:, create_at_start_of_period:, schedule_type:)
    end

    let(:scheduled_date) { '2025-07-20' }
    let(:schedule_type) { :month }

    context 'when create_at_start_of_period is false' do
      let(:create_at_start_of_period) { false }

      it { is_expected.to eq('Next transaction: 2025-07-20') }
    end

    context 'when create_at_start_of_period is true' do
      let(:create_at_start_of_period) { true }

      it { is_expected.to eq('Will run at the start of the month') }
    end
  end
end
