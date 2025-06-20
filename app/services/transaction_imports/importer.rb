# frozen_string_literal: true

module TransactionImports
  class Importer
    attr_reader :import, :statistics_recorder, :parser

    IMPORTER_ACTION_CLASSES = {
      'import' => TransactionImports::ImportActions::ImportTransaction,
      'match'  => TransactionImports::ImportActions::MatchTransaction
    }.freeze

    def initialize(import)
      @import              = import
      @parser              = TransactionImports::BaseParser.parser_for(import)
      @statistics_recorder = TransactionImports::ImportStatistics.new
    end

    def import!
      ActiveRecord::Base.transaction do
        filtered_import_transactions.each do |import_transaction|
          import_transaction!(import_transaction)
        end

        reference_dates = filtered_import_transactions.map(&:transaction_date)
        Budgets::UpdateProfileBudgetInstancesService.call(import.profile, reference_dates)

        import.finished!
      rescue ActiveRecord::ActiveRecordError
        raise ActiveRecord::Rollback
      end

      import.reload.finished?
    end

    private

    def filtered_import_transactions
      import
        .import_transactions
        .includes({ wallet: :profile }, :category, :subcategory)
        .select { |import_transaction| !import_transaction.skip? && !import_transaction.block? }
    end

    def import_transaction!(import_transaction)
      importer_klass = IMPORTER_ACTION_CLASSES[import_transaction.action]
      if importer_klass
        importer_klass.execute!(import, import_transaction, parser, statistics_recorder)
      else
        statistics_recorder.record_error(import_transaction, :unknown_action_id)
      end
    end
  end
end
