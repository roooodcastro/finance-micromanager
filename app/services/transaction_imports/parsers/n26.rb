# frozen_string_literal: true

module TransactionImports
  module Parsers
    class N26 < BaseParser
      # CSV variables
      #
      FIRST_TRANSACTION_ROW_CSV = 1

      # PDF variables
      #
      # Example transactions from N26:
      #
      # From Instant Savings                                            03.09.2024                  +10,00€\n\n
      # Value Date 03.09.2024\n\n
      #
      # Coffee Shop                                                     07.09.2024                     -4,50€\n
      # Mastercard • Leisure\n
      # Value Date 06.09.2024\n\n
      #
      # Online Store                                                    12.09.2024                     -17,94€\n
      # Mastercard • Healthcare & Drug Stores\n
      # Original amount 110,00 BRL | Exchange rate 0,16309\n
      # Value Date 11.09.2024\n\n
      #
      # NAME_REGEX will match the name before the first date
      # BOOKING_DATE_REGEX will match the date after the name. This date is when the transaction was processed by N26
      # AMOUNT_REGEX will match the amount
      # CATEGORY_REGEX will match the OPTIONAL line specifying the card provider and category
      # FOREIGN_EXCHANGE_REGEX will match the OPTIONAL line specifying exchange rate information (foreign purchases)
      # VALUE_DATE_REGEX will match the last line with the actual date the transaction was made
      #
      # Not all of the transaction block will be matched, some parts like line breaks and the "Value Date" string will
      # just be ignored, for instance.
      #
      NAME_REGEX             = /^([\w \.,&|'"\-\(\)\[\]\{\}]+)\s{2,}/
      BOOKING_DATE_REGEX     = /(\d\d\.\d\d\.\d\d\d\d)\s{2,}/
      AMOUNT_REGEX           = /([-+\d,]+)[^\n]+/
      CATEGORY_REGEX         = /(\n+[[\w\d ,&•'"\(\)\[\]\{\}]]+)?/
      FOREIGN_EXCHANGE_REGEX = /(\n+[[\w\d ,&|'"\(\)\[\]\{\}]]+)?/
      VALUE_DATE_REGEX       = /\n+[^\n]+(\d\d.\d\d.\d\d\d\d)/

      ALL_REGEX_PARTS        = [
        NAME_REGEX,
        BOOKING_DATE_REGEX,
        AMOUNT_REGEX,
        CATEGORY_REGEX,
        FOREIGN_EXCHANGE_REGEX,
        VALUE_DATE_REGEX
      ].freeze

      # Regex to match a transaction block in the N26 statement PDF
      PDF_TRANSACTION_REGEX  = Regexp.new(ALL_REGEX_PARTS.map(&:source).join)

      def parse_file
        if import.source_file.content_type == 'application/pdf'
          parse_pdf_file
        else
          parse_csv_file
        end
      end

      private

      def parse_csv_file
        rows = read_csv_file.then(&method(:filter_non_transaction_rows))
        rows.map do |row|
          original_import_name = build_full_transaction_name(row)
          name                 = original_import_name
          transaction_date     = Date.parse(row[0])
          amount               = row[5].to_f
          wallet               = import.wallet

          TransactionImports::ImportTransaction.new(
            import:, original_import_name:, name:, transaction_date:, amount:, wallet:
          )
        end
      end

      def parse_pdf_file
        transaction_rows = read_pdf_file.flat_map { |page| page.scan(PDF_TRANSACTION_REGEX) }

        transaction_rows.map do |row|
          original_import_name = row[0].strip
          name                 = original_import_name
          transaction_date     = Date.parse(row[5])
          amount               = row[2].sub(',', '.').to_f
          wallet               = import.wallet
          category             = process_n26_category(row)

          TransactionImports::ImportTransaction.new(
            import:, original_import_name:, name:, transaction_date:, amount:, wallet:, category:
          )
        end
      end

      def read_csv_file
        CSV.parse(read_source_file)
      end

      def read_pdf_file
        import.source_file.open { |io| PDF::Reader.new(io).pages.map(&:text) }
      end

      def filter_non_transaction_rows(csv_rows)
        csv_rows[FIRST_TRANSACTION_ROW_CSV..]
      end

      def build_full_transaction_name(csv_row)
        [csv_row[1], csv_row[2], csv_row[4]].map do |part|
          part.to_s.gsub('-', '').strip.presence
        end.uniq.compact.join(' ')
      end

      def process_n26_category(pdf_row)
        n26_category = pdf_row[3].to_s.split('•')[1].to_s.strip.presence
        return unless n26_category

        profile_categories.find { |category| category.name.downcase == n26_category.downcase }
      end

      def profile_categories
        @profile_categories ||= import.profile.categories
      end

      def source
        'n26'
      end
    end
  end
end
