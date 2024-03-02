# frozen_string_literal: true

ActiveSupport.on_load(:active_record) do
  module ActiveRecord
    class Relation
      def like(column_name, value)
        where(like_condition(column_name, value))
      end

      private

      def like_condition(column_name, value)
        attribute = ActiveRecord::Relation::QueryAttribute.new(column_name, value, ActiveModel::Type::String.new)
        pattern   = Arel::Nodes::BindParam.new(attribute)

        arel_table[column_name].matches(pattern)
      end
    end
  end
end
