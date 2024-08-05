# frozen_string_literal: true

module TransactionImports
  class Importer
    attr_reader :import, :statistics_recorder, :parser

    IMPORTER_ACTION_CLASSES = {
      import: TransactionImports::ImportActions::ImportTransaction,
      match:  TransactionImports::ImportActions::MatchTransaction
    }.freeze

    def initialize(import)
      @import              = import
      @parser              = TransactionImports::BaseParser.parser_for(import)
      @statistics_recorder = TransactionImports::ImportStatistics.new
    end

    def import!(preview_transaction_attributes)
      ActiveRecord::Base.transaction do
        import_transactions_to_import(preview_transaction_attributes).each do |transaction_to_import|
          import_transaction!(transaction_to_import)
        end

        import.finished!
      rescue ActiveRecord::ActiveRecordError
        raise ActiveRecord::Rollback
      end

      import.reload.finished?
    end

    private

    def parsed_import_transactions
      @parsed_import_transactions ||= parser.parse
    end

    def import_transactions_to_import(preview_transaction_attributes)
      parsed_import_transactions.each_with_object([]) do |parsed_transaction, result|
        transaction_attributes = preview_transaction_attributes[parsed_transaction.id]
        next unless transaction_attributes

        parsed_transaction.assign_attributes(sanitize_transaction_attributes(transaction_attributes))
        next if parsed_transaction.skip_or_block?

        result << parsed_transaction
      end
    end

    def sanitize_transaction_attributes(attributes)
      attributes[:transaction_date] = Date.parse(attributes[:transaction_date]) if attributes[:transaction_date]
      attributes[:action_id]        = attributes[:action_id].to_sym if attributes[:action_id].present?

      attributes.slice(:name, :transaction_date, :action_id, :match_transaction_id, :category_id)
    end

    def import_transaction!(transaction_to_import)
      importer_klass = IMPORTER_ACTION_CLASSES[transaction_to_import.action_id]
      if importer_klass
        importer_klass.execute!(import, transaction_to_import, parser, statistics_recorder)
      else
        statistics_recorder.record_error(transaction_to_import, :unknown_action_id)
      end
    end
  end
end
