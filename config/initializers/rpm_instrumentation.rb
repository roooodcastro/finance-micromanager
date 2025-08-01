# frozen_string_literal: true

require 'new_relic/agent/method_tracer'

Rails.application.config.after_initialize do
  TransactionImports::ImportTransactionProcessors::ImportNamesProcessor.class_eval do
    include ::NewRelic::Agent::MethodTracer

    add_method_tracer :call
    add_method_tracer :process_import_names
  end

  TransactionImports::ImportTransactionProcessors::TransactionsMatcher.class_eval do
    include ::NewRelic::Agent::MethodTracer

    add_method_tracer :call
    add_method_tracer :match_data_for
  end

  TransactionImports::ImportTransactionProcessors::DefaultActionSetter.class_eval do
    include ::NewRelic::Agent::MethodTracer

    add_method_tracer :call
    add_method_tracer :action_for
    add_method_tracer :top_match_data_for
    add_method_tracer :minimum_transaction_date
  end

  TransactionPredictions::RulesProcessor.class_eval do
    include ::NewRelic::Agent::MethodTracer

    add_method_tracer :process_transaction
  end

  TransactionImports::TransactionMatcher.class_eval do
    include ::NewRelic::Agent::MethodTracer

    add_method_tracer :call
  end
end
