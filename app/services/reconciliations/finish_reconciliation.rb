# frozen_string_literal: true

module Reconciliations
  class FinishReconciliation < ApplicationService
    attr_reader :reconciliation

    def self.call(reconciliation)
      new(reconciliation).call
    end

    def initialize(reconciliation)
      super()
      @reconciliation = reconciliation
    end

    def call
      reconciliation.finished!
      true
    end
  end
end
