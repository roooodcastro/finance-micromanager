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
      import_transactions = parse.compact
      import_transactions.each do |import_transaction|
        import_transaction.find_matches(transactions_to_match)
        import_transaction.revert_to_default_action(minimum_transaction_date)
      end
      import_transactions.map(&:as_json)
    end

    # def import!
    #   parsed_transactions = parse.compact.map { |row| build_transaction(*row) }.compact
    #   return if parsed_transactions.empty?
    #
    #   ActiveRecord::Base.transaction do
    #     import = Import.create!(source: source, profile: Current.profile, wallet: wallet)
    #     parsed_transactions.each { |transaction| transaction.update!(import:) }
    #   rescue ActiveRecord::ActiveRecordError
    #     raise ActiveRecord::Rollback
    #   end
    # end

    def parse
      raise NotImplementedError
    end

    private

    # def build_transaction(raw_import_name, name, transaction_date, amount, category = nil)
    #   return if Transaction.exists?(
    #     raw_import_name:  raw_import_name,
    #     transaction_date: transaction_date,
    #     amount_cents:     amount.to_f * 100,
    #     profile:          Current.profile
    #   )
    #
    #   Transaction.new(
    #     name:             name,
    #     amount:           amount,
    #     transaction_date: transaction_date,
    #     raw_import_name:  raw_import_name,
    #     profile:          Current.profile,
    #     created_by:       Current.user,
    #     updated_by:       Current.user,
    #     category:         category || transaction_category(raw_import_name),
    #     wallet:           wallet
    #   )
    # end

    # def transaction_category(_raw_import_name)
    #   temporary_category
    # end

    # def temporary_category
    #   @temporary_category ||= Category.temporary_category_for(Current.profile)
    # end

    # All "active" transactions for the profile, meaning all the transactions after the latest reconciliation date
    def transactions_to_match
      @transactions_to_match ||= import
                                 .profile
                                 .transactions
                                 .includes(:category, :subcategory, wallet: :profile)
                                 .newer_than(minimum_transaction_date)
                                 .to_a
    end

    def minimum_transaction_date
      return unless import.profile.latest_reconciliation

      import.profile.latest_reconciliation.date.to_date + 1.day
    end

    def read_source_file
      @read_source_file ||= import.source_file.open(&:read)
    end

    def source
      raise NotImplementedError
    end
  end
end
