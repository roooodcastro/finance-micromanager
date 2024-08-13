# frozen_string_literal: true

module TransactionImports
  class CancelImport < ApplicationService
    attr_reader :import

    def initialize(import)
      @import = import
    end

    def call
      ActiveRecord::Base.transaction do
        import.cancelled!
        import.source_file.purge
      rescue ActiveRecord::ActiveRecordError
        raise ActiveRecord::Rollback
      end
    end
  end
end
