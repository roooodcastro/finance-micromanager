# frozen_string_literal: true

module Imports
  class ImportTransactionsController < AbstractAuthenticatedController
    before_action :set_import
    before_action :set_import_transaction, only: %i[update]

    def index
      import_transactions = @import.import_transactions
                                   .includes(:wallet, :category, :subcategory)
                                   .order(transaction_date: :desc, original_import_name: :asc)

      TransactionImports::ImportTransactionProcessors::BaseProcessor.run_pipeline(@import, import_transactions)

      render json: camelize_props(import_transactions: import_transactions.as_json)
    end

    def update
      @import_transaction.assign_attributes(update_params)
      TransactionImports::ImportTransactionProcessors::BaseProcessor
        .run_pipeline(@import_transaction.import, [@import_transaction])

      if @import_transaction.valid?
        render json: camelize_props(message: t('.success'), import_transaction: @import_transaction.as_json)
      else
        error = @import_transaction.error_messages
        render json:   camelize_props(message: t('.error', error:)),
               status: :unprocessable_entity
      end
    end

    private

    def set_import
      @import = Current.profile.imports.find(params[:import_id])
    end

    def set_import_transaction
      @import_transaction = @import.import_transactions.find(params[:id])
    end

    def update_params
      params
        .expect(import_transaction: %i[name category_id subcategory_id transaction_date action match_transaction_id])
        .then { |permitted_params| process_category_id_param(permitted_params) }
    end

    def process_category_id_param(permitted_params)
      return permitted_params unless permitted_params[:category_id]

      permitted_params[:category_id], permitted_params[:subcategory_id] = Category.split_compose_category_id(
        permitted_params[:category_id]
      )

      if Category.exists?(id: permitted_params[:category_id], category_type: :system)
        permitted_params.delete(:category_id)
      end

      permitted_params
    end
  end
end
