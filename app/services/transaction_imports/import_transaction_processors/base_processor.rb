# frozen_string_literal: true

module TransactionImports
  module ImportTransactionProcessors
    class BaseProcessor < ApplicationService
      attr_reader :import, :import_transactions

      PROCESSORS = [
        'TransactionImports::ImportTransactionProcessors::TransactionsMatcher',
        'TransactionImports::ImportTransactionProcessors::DefaultActionSetter',
        'TransactionImports::ImportTransactionProcessors::ImportNamesProcessor'
      ].freeze

      def self.run_pipeline(import, import_transactions, save: true)
        PROCESSORS.each { |processor_class| processor_class.constantize.call(import, import_transactions) }

        import_transactions.each(&:save) if save
      end

      def initialize(import, import_transactions)
        @import              = import
        @import_transactions = import_transactions
      end
    end
  end
end
