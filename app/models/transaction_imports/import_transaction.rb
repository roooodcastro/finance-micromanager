# frozen_string_literal: true

module TransactionImports
  class ImportTransaction
    include ActiveModel::Model
    include Comparable

    attr_accessor :import, :import_file_index, :original_import_name, :name, :transaction_date, :amount, :category_id,
                  :wallet_id, :action_id, :matches, :match_transaction_id

    # Maximum difference in days between two dates so they can be considered to have a half match
    DATE_MATCH_DAYS_THRESHOLD = 7
    # Maximum difference in currency units between two amounts so they can be considered to have a half match
    AMOUNT_MATCH_THRESHOLD    = 0.1
    # Minimum match score so that a transaction can be considered to match with this import transaction
    MATCH_SCORE_THRESHOLD     = 1.5

    DOUBLE_IMPORT_MATCH_SCORE = -1
    EXACT_MATCH_SCORE         = 5

    def initialize(*)
      super

      # Calculate and memoize ID
      id
      # Set default action
      revert_to_default_action(nil)
    end

    def id
      @id ||= begin
        data_for_id = [import_file_index, original_import_name, transaction_date, amount].join('-')
        Digest::UUID.uuid_from_hash(Digest::SHA1, Digest::UUID::DNS_NAMESPACE, data_for_id)
      end
    end

    def attributes_for_transaction
      {
        profile:           Current.profile,
        name:              name,
        raw_import_name:   original_import_name,
        transaction_date:  transaction_date,
        amount:            amount,
        category_id:       Category.split_compose_category_id(category_id).first,
        subcategory_id:    Category.split_compose_category_id(category_id).second,
        wallet_id:         wallet_id,
        import_preview_id: id,
        updated_by:        Current.user
      }
    end

    def skip_or_block?
      %i[skip block].include?(action_id.to_s.to_sym)
    end

    def find_matches(transactions)
      @matches = transactions.each_with_object([]) do |transaction, result|
        match_score    = match_score_for(transaction)
        self.action_id = :skip if match_score == DOUBLE_IMPORT_MATCH_SCORE
        next if match_score < MATCH_SCORE_THRESHOLD

        result << { transaction:, match_score: }
      end

      @matches.sort_by! { |match| -match[:match_score] }

      self.action_id = :match if matches.present? && action_id != :skip
    end

    def revert_to_default_action(minimum_date)
      return self.action_id = :block if minimum_date && transaction_date < minimum_date
      return self.action_id = :match if matches.present?

      self.action_id = :import unless action_id == :skip
    end

    def ==(other)
      id == other&.id && action_id == other&.action_id && name == other&.name && category_id == other&.category_id
    end

    def <=>(other)
      return 0 if transaction_date.blank? || other.transaction_date.blank?

      return -1 if other.transaction_date > transaction_date
      return 1 if other.transaction_date < transaction_date

      0
    end

    def match_score_for(transaction)
      return DOUBLE_IMPORT_MATCH_SCORE if transaction.import_id.present? && transaction.import_id != import.id
      return EXACT_MATCH_SCORE if id == transaction.import_preview_id

      name_match_score(transaction) + date_match_score(transaction) + amount_match_score(transaction)
    end

    private

    def name_match_score(transaction)
      return 1 if transaction.name == name

      0
    end

    def date_match_score(transaction)
      return 0 unless transaction_date
      return 1 if transaction.transaction_date.to_date == transaction_date.to_date
      return 0.5 if (transaction.transaction_date.to_date - transaction_date.to_date).abs < DATE_MATCH_DAYS_THRESHOLD

      0
    end

    def amount_match_score(transaction)
      return 1 if (transaction.amount.to_d - amount.to_d).abs < Float::EPSILON
      return 0.5 if (transaction.amount.to_d - amount.to_d).abs < AMOUNT_MATCH_THRESHOLD

      0
    end
  end
end
