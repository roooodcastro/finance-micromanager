# frozen_string_literal: true

module Importer
  class Base
    attr_reader :import

    IMPORTER_CLASSES = {
      ptsb: ::Importer::PTSB,
      n26:  ::Importer::N26
    }.freeze

    def self.generate_preview(import)
      importer = importer_for(import)
      importer.generate_preview
    end

    def self.importer_for(import)
      raise ArgumentError, "Import source unknown: #{import.source}" unless IMPORTER_CLASSES[import.source.to_sym]

      IMPORTER_CLASSES[import.source.to_sym].new(import)
    end

    def initialize(import)
      @import = import
    end

    def generate_preview
      parsed_rows            = parse.compact
      transactions_by_row_id = Transaction
                               .where(import_preview_id: parsed_rows.pluck(:id))
                               .group_by(&:import_preview_id)

      parsed_rows.map do |row|
        {
          id:               row[:id],
          raw_import_name:  row[:import_name],
          name:             row[:transaction_name],
          transaction_date: row[:transaction_date],
          amount:           row[:amount],
          wallet_id:        import.wallet.id,
          action_id:        action_id_for(row, transactions_by_row_id),
          matches:          (transactions_by_row_id[row[:id]] || []).as_json
        }
      end
    end

    def import!
      parsed_transactions = parse.compact.map { |row| build_transaction(*row) }.compact
      return if parsed_transactions.empty?

      ActiveRecord::Base.transaction do
        import = Import.create!(source: source, profile: Current.profile, wallet: wallet)
        parsed_transactions.each { |transaction| transaction.update!(import:) }
      rescue ActiveRecord::ActiveRecordError
        raise ActiveRecord::Rollback
      end
    end

    def parse
      raise NotImplementedError
    end

    private

    def build_transaction(raw_import_name, name, transaction_date, amount, category = nil)
      return if Transaction.exists?(
        raw_import_name:  raw_import_name,
        transaction_date: transaction_date,
        amount_cents:     amount.to_f * 100,
        profile:          Current.profile
      )

      Transaction.new(
        name:             name,
        amount:           amount,
        transaction_date: transaction_date,
        raw_import_name:  raw_import_name,
        profile:          Current.profile,
        created_by:       Current.user,
        updated_by:       Current.user,
        category:         category || transaction_category(raw_import_name),
        wallet:           wallet
      )
    end

    def transaction_category(_raw_import_name)
      temporary_category
    end

    def temporary_category
      @temporary_category ||= Category.temporary_category_for(Current.profile)
    end

    def read_source_file
      @read_source_file ||= import.source_file.open(&:read)
    end

    def calculate_transaction_id(row)
      Digest::UUID.uuid_from_hash(Digest::SHA1, Digest::UUID::DNS_NAMESPACE, row.join('-'))
    end

    def action_id_for(row, transactions_by_row_id)
      return :match if transactions_by_row_id[row[:id]].present?

      :import
    end

    def source
      raise NotImplementedError
    end
  end
end
