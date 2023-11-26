# frozen_string_literal: true

class ApplicationSerializer
  attr_reader :record

  def initialize(record)
    @record = record
  end

  def self.from_collection(records)
    records.map { |record| new(record) }
  end

  def as_json(*)
    raise NotImplementedError
  end
end
