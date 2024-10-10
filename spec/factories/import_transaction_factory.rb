# frozen_string_literal: true

FactoryBot.define do
  factory :import_transaction, class: 'TransactionImports::ImportTransaction' do
    sequence(:original_import_name, 'ORIGINAL_TRANSACTION_AAA')
    sequence(:name, 'Transaction AAA')
    amount { 10.00 }
    transaction_date { Time.current }
    action { 'import' }

    import
    wallet
  end
end
