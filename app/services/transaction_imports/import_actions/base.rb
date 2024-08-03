# frozen_string_literal: true

module TransactionImports
  module ImportActions
    class Base
      attr_reader :import, :import_transaction, :parser, :statistics_recorder

      def self.execute!(import, import_transaction, parser, statistics_recorder)
        new(import, import_transaction, parser, statistics_recorder).execute
      end

      def initialize(import, import_transaction, parser, statistics_recorder)
        @import              = import
        @import_transaction  = import_transaction
        @parser              = parser
        @statistics_recorder = statistics_recorder
      end

      def execute
        raise NotImplementedError
      end

      private

      def record_error(reason_i18n_key, i18n_attributes = {})
        statistics_recorder.record_error(import_transaction, reason_i18n_key, i18n_attributes)
      end
    end
  end
end
