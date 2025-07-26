# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.implicit_order_column = :created_at

  primary_abstract_class

  def error_messages
    errors.full_messages.join(', ')
  end

  def self.human_enum_name(enum_name, enum_value, **)
    I18n.t("activerecord.attributes.#{model_name.i18n_key}.#{enum_name.to_s.pluralize}.#{enum_value}", **)
  end
end
