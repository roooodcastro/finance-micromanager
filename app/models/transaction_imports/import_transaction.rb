# frozen_string_literal: true

module TransactionImports
  class ImportTransaction < ApplicationRecord
    attr_accessor :matches, :import_name_object

    monetize :amount_cents, disable_validation: true, with_currency: ->(instance) { instance.currency }

    validates :original_import_name, :name, :amount, :transaction_date, :action, presence: true

    belongs_to :import
    belongs_to :wallet
    belongs_to :category, optional: true
    belongs_to :subcategory, optional: true
    belongs_to :match_transaction, class_name: 'Transaction', optional: true

    enum action: { import: 'import', skip: 'skip', match: 'match', block: 'block' }, _default: 'import'

    def currency
      import&.profile&.currency || Money.default_currency
    end

    def as_json(*)
      super(except: %w[created_at updated_at])
        .merge(
          'amount'      => amount.to_f,
          'subcategory' => subcategory.as_json,
          'wallet'      => wallet.as_json,
          'category'    => category.as_json(include_subcategories: false),
          'matches'     => matches,
          'import_name' => import_name_object
        )
    end

    def attributes_for_transaction
      {
        profile:           Current.profile,
        name:              name,
        raw_import_name:   original_import_name,
        transaction_date:  transaction_date,
        amount:            amount,
        category:          category,
        subcategory:       subcategory,
        wallet:            wallet,
        import_preview_id: id,
        updated_by:        Current.user
      }
    end

    def assign_match_transaction(transaction_to_match)
      self.match_transaction = transaction_to_match

      if transaction_to_match
        self.name             = transaction_to_match.name
        self.transaction_date = transaction_to_match.transaction_date
        self.amount           = transaction_to_match.amount
        self.category         = transaction_to_match.category
        self.subcategory      = transaction_to_match.subcategory
      else
        self.name        = original_import_name
        self.category    = nil
        self.subcategory = nil
      end
    end
  end
end
