# frozen_string_literal: true

module TransactionImports
  class BaseParser
    attr_reader :import

    PARSER_CLASSES = {
      ptsb: ::TransactionImports::Parsers::PTSB,
      n26:  ::TransactionImports::Parsers::N26
    }.freeze

    def self.generate_preview(import)
      parser = parser_for(import)
      parser.generate_preview
    end

    def self.parser_for(import)
      raise ArgumentError, "Import source unknown: #{import.source}" unless PARSER_CLASSES[import.source.to_sym]

      PARSER_CLASSES[import.source.to_sym].new(import)
    end

    def initialize(import)
      @import = import
    end

    def generate_preview
      import_transactions = parse.compact.sort.reverse
      import_transactions.each do |import_transaction|
        import_transaction.find_matches(transactions_to_match)
        import_transaction.revert_to_default_action(minimum_transaction_date)
      end
      import_transactions.map(&:as_json)
    end

    def parse
      raise NotImplementedError
    end

    # All "active" transactions for the profile, meaning all the transactions after the latest reconciliation date
    def transactions_to_match
      @transactions_to_match ||= import
                                 .profile
                                 .transactions
                                 .includes(:category, :subcategory, wallet: :profile)
                                 .newer_than(minimum_transaction_date)
                                 .where(wallet: import.wallet)
                                 .to_a
    end

    private

    def minimum_transaction_date
      return unless import.profile.latest_reconciliation

      import.profile.latest_reconciliation.date.to_date + 1.day
    end

    def process_import_names(name)
      import_names.find { |import_name| import_name.import_name == name }&.transaction_name || name
    end

    def import_names
      @import_names ||= import.profile.import_names.to_a
    end

    def read_source_file
      @read_source_file ||= import.source_file.open(&:read)
    end

    def source
      raise NotImplementedError
    end
  end
end
