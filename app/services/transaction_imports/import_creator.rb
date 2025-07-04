# frozen_string_literal: true

module TransactionImports
  class ImportCreator < ApplicationService
    attr_reader :import_params, :import

    def initialize(import_params)
      @import_params = import_params
    end

    def call
      Current.profile.imports.new(import_params).tap do |import|
        import.save && TransactionImports::BaseParser.parser_for(import).parse!
        import.destroy if import.cancelled?
      end
    end
  end
end
