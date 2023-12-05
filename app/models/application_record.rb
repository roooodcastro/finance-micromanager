# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.implicit_order_column = :created_at

  primary_abstract_class
end
