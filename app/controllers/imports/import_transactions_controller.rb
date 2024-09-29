# frozen_string_literal: true

module Imports
  class ImportTransactionsController < AbstractAuthenticatedController
    before_action :set_import_transaction, only: %i[update]

    def update
      if @import_transaction.update(update_params)
        TransactionImports::ImportTransactionProcessors::BaseProcessor
          .run_pipeline(@import_transaction.import, [@import_transaction])

        render json: camelize_props(message: t('.success'), import_transaction: @import_transaction.as_json)
      else
        error = @import_transaction.error_messages
        render json:   camelize_props(message: t('.error', error:)),
               status: :unprocessable_entity
      end
    end

    private

    def set_import_transaction
      @import_transaction = TransactionImports::ImportTransaction.find(params[:id])
    end

    def update_params
      params
        .require(:import_transaction)
        .permit(%i[name category_id subcategory_id transaction_date action])
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
