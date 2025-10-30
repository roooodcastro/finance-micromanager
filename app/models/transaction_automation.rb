# frozen_string_literal: true

class TransactionAutomation < ApplicationRecord
  include Disableable

  monetize :transaction_amount_cents, disable_validation: true, with_currency: ->(instance) { instance.currency }

  belongs_to :profile
  belongs_to :transaction_category, class_name: 'Category'
  belongs_to :transaction_subcategory, class_name: 'Subcategory', optional: true
  belongs_to :transaction_wallet, class_name: 'Wallet', optional: true

  has_many :transactions, dependent: :nullify

  enum :weekend_rule, { allow: 'allow', friday: 'friday', monday: 'monday' }, prefix: true, default: nil

  validates :schedule_type, :scheduled_date, :transaction_name, :transaction_amount, presence: true
  validates :schedule_interval, numericality: { only_integer: true, greater_than: 0 }, unless: :schedule_type_custom?
  validates :schedule_interval, absence: true, if: :schedule_type_custom?
  validates :schedule_custom_rule, absence: true, unless: :schedule_type_custom?
  validates :schedule_custom_rule, inclusion: { in: -> { TransactionAutomations::CustomRule.available_rules } },
                                   if:        :schedule_type_custom?
  validates :schedule_day, presence: true, if: -> { schedule_type_month? || schedule_type_week? }
  validates :schedule_day, absence: true, unless: -> { schedule_type_month? || schedule_type_week? }
  validates :weekend_rule, presence: true, if: -> { schedule_type_month? || schedule_type_day? }
  validates :weekend_rule, absence: true, unless: -> { schedule_type_month? || schedule_type_day? }
  validates :schedule_day, numericality: { only_integer: true, in: (0..6) }, if: -> { schedule_type_week? }
  validates :schedule_day, numericality: { only_integer: true, in: (1..31) }, if: -> { schedule_type_month? }

  before_validation :set_initial_scheduled_date

  validates_with ::TransactionAutomationValidator

  enum :schedule_type, { month: 'M', week: 'W', day: 'D', custom: 'C' }, prefix: :schedule_type

  def as_json
    super(except: %w[schedule_type transaction_amount_cents]).merge(
      schedule_type:           self.class.schedule_types[schedule_type],
      schedule_type_key:       schedule_type,
      transaction_amount:      transaction_amount.to_f,
      transaction_category:    transaction_category.as_json(include_subcategories: false),
      transaction_subcategory: transaction_subcategory.as_json,
      transaction_wallet:      transaction_wallet.as_json,
      humanized_schedule:      humanized_schedule,
      humanized_next_run:      humanized_next_run,
      next_run_at:             next_run_at.iso8601
    )
  end

  def currency
    profile&.currency || Money.default_currency
  end

  def bump_scheduled_date!
    return unless next_scheduled_date(scheduled_date)

    update!(scheduled_date: next_scheduled_date(scheduled_date))
  end

  def transaction_attributes
    {
      name:                      transaction_name,
      amount:                    transaction_amount,
      transaction_date:          scheduled_date,
      profile_id:                profile_id,
      category_id:               transaction_category_id,
      subcategory_id:            transaction_subcategory_id,
      wallet_id:                 transaction_wallet_id,
      transaction_automation_id: id,
      created_by_id:             profile.user_id,
      updated_by_id:             profile.user_id
    }
  end

  def next_run_at
    return scheduled_date unless create_at_start_of_period?
    return scheduled_date.beginning_of_week if schedule_type_week?

    scheduled_date.beginning_of_month
  end

  def humanized_schedule
    return self.class.human_enum_name(:schedule_custom_rule, schedule_custom_rule) if schedule_type_custom?

    schedule_type_part = self.class.human_enum_name(:schedule_type, schedule_type, count: schedule_interval)
    schedule_day_part  = if schedule_type_week?
                           week_day = I18n.t('date.day_names')[schedule_day.to_i]
                           self.class.human_enum_name(:schedule_days, :week, day: week_day)
                         elsif schedule_type_month?
                           self.class.human_enum_name(:schedule_days, :month, day: schedule_day.to_i)
                         end

    [schedule_type_part, schedule_day_part].compact.join(' ')
  end

  def humanized_next_run
    if create_at_start_of_period
      self.class.human_enum_name(:schedule_next_run, schedule_type, date: I18n.l(scheduled_date.to_date))
    else
      self.class.human_enum_name(:schedule_next_run, :day, date: I18n.l(scheduled_date.to_date))
    end
  end

  private

  def next_scheduled_date(current_date)
    return next_monthly_scheduled_date(current_date) if schedule_type_month?
    return next_weekly_scheduled_date(current_date) if schedule_type_week?
    return next_daily_scheduled_date(current_date) if schedule_type_day?
    return custom_rule.next_scheduled_date(current_date) if schedule_type_custom?

    nil
  end

  def next_weekly_scheduled_date(current_date)
    return if schedule_day.blank? || schedule_interval.blank?

    (current_date + schedule_interval.weeks).beginning_of_week(Date::DAYNAMES[schedule_day].downcase.to_sym)
  end

  def next_monthly_scheduled_date(current_date)
    return if schedule_day.blank? || schedule_interval.blank?

    next_date = begin
      date = current_date + schedule_interval.months
      date.change(day: schedule_day)
    rescue Date::Error
      # Edge case when schedule_day is set to 31, and the next month only has 30 or less days
      (current_date + schedule_interval.months).end_of_month
    end

    apply_weekend_rule(next_date)
  end

  def next_daily_scheduled_date(current_date)
    apply_weekend_rule(current_date + schedule_interval.days)
  end

  def apply_weekend_rule(next_date)
    return next_date.prev_occurring(:friday) if weekend_rule_friday? && next_date.on_weekend?
    return next_date.next_occurring(:monday) if weekend_rule_monday? && next_date.on_weekend?

    next_date
  end

  def custom_rule
    @custom_rule ||= ::TransactionAutomations::CustomRule.new(self)
  end

  def set_initial_scheduled_date
    return if scheduled_date

    self.scheduled_date = next_scheduled_date(Time.current)
  end
end
