# frozen_string_literal: true

module Importer
  class GoogleSheets < Base
    FIRST_DEBTS_COLUMN   = 12
    LAST_DEBTS_COLUMN    = 15
    FIRST_CREDITS_COLUMN = 17
    LAST_CREDITS_COLUMN  = 19

    FIRST_FIXED_DEBITS_ROW  = 5
    LAST_FIXED_DEBITS_ROW   = 25
    FIRST_FIXED_CREDITS_ROW = 5
    LAST_FIXED_CREDITS_ROW  = 25
    FIRST_DAILY_DEBITS_ROW  = 30

    CATEGORY_MAP = {
      'Home'  => 'House',
      'Gym'   => 'Subscriptions',
      'Gifts' => 'Gifts/Transfers'
    }.freeze

    def parse
      spreadsheet = read_file

      Date::MONTHNAMES.compact.flat_map do |month_name|
        next unless spreadsheet.sheets.include?(month_name)

        entries = spreadsheet.sheet(month_name).entries

        debit_rows  = debits(entries)
        credit_rows = credits(entries)

        (debit_rows + credit_rows).map { |row| process_row(row, month_name) }
      end
    end

    private

    def read_file
      Roo::Spreadsheet.open(Rails.root.join(file_name).to_s)
    end

    def source
      'sheets'
    end

    def process_row(row, month_name)
      name             = row[2]
      amount           = row[1] * -1
      category_name    = CATEGORY_MAP[row[3]] || row[3] || 'Money In'
      transaction_date = transaction_date_for_row(row, month_name)

      [name, name, transaction_date, amount, category_for(category_name)]
    end

    def transaction_date_for_row(row, month_name)
      if row[0].is_a?(Numeric)
        month_number = Date::MONTHNAMES.index(month_name)
        Time.zone.parse("2023-#{month_number}-#{row[0]}").to_date
      else
        row[0]
      end
    end

    def debits(entries)
      debit_rows   = entries.pluck(FIRST_DEBTS_COLUMN..LAST_DEBTS_COLUMN)
      fixed_debits = debit_rows[FIRST_FIXED_DEBITS_ROW..LAST_FIXED_DEBITS_ROW]
      daily_debits = debit_rows[FIRST_DAILY_DEBITS_ROW..]
      (fixed_debits + daily_debits).map(&:compact).reject(&:empty?)
    end

    def credits(entries)
      credit_rows = entries.pluck(FIRST_CREDITS_COLUMN..LAST_CREDITS_COLUMN)
      credit_rows[FIRST_FIXED_CREDITS_ROW..LAST_FIXED_CREDITS_ROW].map(&:compact).reject(&:empty?)
    end

    def category_for(category_name)
      @category_for ||= {}
      return @category_for[category_name] if @category_for[category_name]

      category = Current.account.categories.find_or_create_by(name: category_name) do |new_category|
        new_category.color = Category::TEMPORARY_COLOR
      end

      @category_for[category_name] = category
    end
  end
end
