# frozen_string_literal: true

RSpec.describe TransactionAutomations::CustomRule do
  describe '.next_scheduled_date' do
    subject { custom_rule.next_scheduled_date(current_date) }

    let(:custom_rule) { described_class.new(transaction_automation) }
    let(:transaction_automation) { instance_double(TransactionAutomation, schedule_custom_rule:) }

    context 'when the rule is last_day_of_month' do
      let(:schedule_custom_rule) { 'last_day_of_month' }
      let(:current_date) { Date.parse('2024-01-15') }

      it { is_expected.to eq Date.parse('2024-02-29') }
    end

    context 'when the rule is first_business_day_of_month' do
      let(:schedule_custom_rule) { 'first_business_day_of_month' }

      context 'and first day of month is a business day' do
        let(:current_date) { Date.parse('2024-01-15') }

        it { is_expected.to eq Date.parse('2024-02-01') }
      end

      context 'and first day of month is not a business day' do
        let(:current_date) { Date.parse('2024-05-04') }

        it { is_expected.to eq Date.parse('2024-06-03') }
      end
    end

    context 'when the rule is last_business_day_of_month' do
      let(:schedule_custom_rule) { 'last_business_day_of_month' }

      context 'and last day of month is a business day' do
        let(:current_date) { Date.parse('2024-01-15') }

        it { is_expected.to eq Date.parse('2024-02-29') }
      end

      context 'and last day of month is not a business day' do
        let(:current_date) { Date.parse('2024-02-14') }

        it { is_expected.to eq Date.parse('2024-03-29') }
      end
    end

    context 'when the rule is another (invalid)' do
      let(:schedule_custom_rule) { 'invalid' }

      let(:current_date) { Date.parse('2024-01-15') }

      it { is_expected.to be_nil }
    end
  end
end
