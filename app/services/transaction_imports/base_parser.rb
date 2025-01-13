# frozen_string_literal: true

module TransactionImports
  class BaseParser
    class WrongCsvFileFormatError < ArgumentError; end

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
                            .then(&method(:run_import_transaction_pipeline))
                            .then(&method(:process_transaction_predictions))

      ActiveRecord::Base.transaction do
        transaction_imports.each(&:save!)
      rescue ActiveRecord::ActiveRecordError => e
        NewRelic::Agent.notice_error(e)
        raise ActiveRecord::Rollback
      end

      transaction_imports
    rescue WrongCsvFileFormatError => e
      NewRelic::Agent.notice_error(e)
      import.cancelled!
    end

    def parse_file
      raise NotImplementedError
    end

    private

    def run_import_transaction_pipeline(import_transactions)
      TransactionImports::ImportTransactionProcessors::BaseProcessor
        .run_pipeline(import, import_transactions, save: false)

      import_transactions
    end

    def process_transaction_predictions(import_transactions)
      transaction_predictions_processor = TransactionPredictions::RulesProcessor.new(import.profile)

      import_transactions.each do |import_transaction|
        transaction_predictions_processor.process_transaction(import_transaction, %w[name category_id])
      end

      import_transactions
    end

    def read_source_file
      @read_source_file ||= import.source_file.open(&:read)
    end

    def source
      raise NotImplementedError
    end
  end
end
