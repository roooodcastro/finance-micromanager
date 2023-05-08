# frozen_string_literal: true

module Importer
  class PTSB < Base
    FIRST_TRANSACTION_ROW  = 13
    LAST_TRANSACTION_ROW   = -2
    TRANSACTION_NAME_REGEX = /([a-z][\w[*]&%$@-]*)\s*/i
    TRANSACTION_DATE_REGEX = %r{\d{2}/\d{2}}i

    def parse
      rows = read_file.then(&method(:filter_non_transaction_rows))
      rows.map do |row|
        raw_name = row[2]
        name     = row[2].scan(TRANSACTION_NAME_REGEX).join(' ')
        date     = extract_date(row)
        amount   = row[3].to_f - row[4].to_f

        [raw_name, name, date, amount]
      end
    end

    private

    def filter_non_transaction_rows(rows)
      rows[FIRST_TRANSACTION_ROW..LAST_TRANSACTION_ROW]
    end

    def read_file
      Roo::Excel.new(Rails.root.join(file_name)).entries
    end

    def extract_date(row)
      return Date.parse(row[0]) unless row[2].match(TRANSACTION_DATE_REGEX)

      statement_date = row[2].match(TRANSACTION_DATE_REGEX)[0]

      current_year_date = parse_date(statement_date, Date.current.year)
      last_year_date    = parse_date(statement_date, Date.current.year - 1)

      current_year_date > Date.current ? last_year_date : current_year_date
    end

    def parse_date(statement_date, year)
      date_parts = statement_date.split('/').reverse
      Date.parse(([year] + date_parts).join('-'))
    end

    def source
      'ptsb'
    end
  end
end
