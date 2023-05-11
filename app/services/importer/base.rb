# frozen_string_literal: true

module Importer
  class Base
    attr_reader :file_name

    def initialize(file_name)
      @file_name = file_name
    end

    def import!
      parsed_transactions = parse.map { |row| build_transaction(*row) }.compact
      return if parsed_transactions.empty?

      ActiveRecord::Base.transaction do
        import = Import.create!(source: source, account: Current.account)
        parsed_transactions.each { |transaction| transaction.update!(import:) }
      rescue ActiveRecord::ActiveRecordError
        raise ActiveRecord::Rollback
      end
    end

    def parse
      raise NotImplementedError
    end

    private

    def build_transaction(raw_import_name, name, transaction_date, amount)
      return if Transaction.exists?(
        raw_import_name: raw_import_name,
        transaction_date: transaction_date,
        amount_cents: amount.to_f * 100,
        account: Current.account
      )

      Transaction.new(name: name, amount: amount, transaction_date: transaction_date, raw_import_name: raw_import_name,
                      account: Current.account)
    end

    def source
      raise NotImplementedError
    end
  end
end
