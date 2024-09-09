# frozen_string_literal: true

module TransactionImports
  class BaseParser
    attr_reader :import

    PARSER_CLASSES = {
      ptsb:    TransactionImports::Parsers::PTSB,
      n26:     TransactionImports::Parsers::N26,
      revolut: TransactionImports::Parsers::Revolut
    }.freeze

    def self.parser_for(import)
      raise ArgumentError, "Import source unknown: #{import.source}" unless PARSER_CLASSES[import.source.to_sym]

      PARSER_CLASSES[import.source.to_sym].new(import)
    end

    def initialize(import)
      @import = import
    end

    def parse!
      transaction_imports = parse_file
                            .then(&method(:find_transaction_matches))
                            .then(&method(:set_default_action))
                            .then(&method(:process_transaction_predictions))

      ActiveRecord::Base.transaction do
        transaction_imports.each(&:save!)
      rescue ActiveRecord::ActiveRecordError => e
        NewRelic::Agent.notice_error(e)
        raise ActiveRecord::Rollback
      end

      transaction_imports
    end

    def parse_file
      raise NotImplementedError
    end

    private

    def process_import_names(name)
      import_names.find { |import_name| import_name.import_name == name }&.transaction_name || name
    end

    def find_transaction_matches(import_transactions)
      TransactionImports::TransactionsMatcher.call(import, import_transactions)
    end

    def set_default_action(import_transactions) # rubocop:disable Naming/AccessorMethodName
      TransactionImports::DefaultActionSetter.call(import, import_transactions)
    end

    def process_transaction_predictions(import_transactions)
      transaction_predictions_processor = TransactionPredictions::RulesProcessor.new(import.profile)

      import_transactions.each do |import_transaction|
        transaction_predictions_processor.process_transaction(import_transaction, %w[name category_id])
      end

      import_transactions
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
