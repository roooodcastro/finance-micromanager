# frozen_string_literal: true

class ApplicationQuery
  class_attribute :wrapper_class

  class QueryBind
    attr_accessor :present, :index
    attr_reader :name, :type

    def initialize(name, type, array: false, default: nil)
      @name    = name
      @type    = type
      @array   = array
      @value   = array ? [] : nil
      @default = default
      @present = false
    end

    def array?
      @array
    end

    def value=(val)
      @value = if array?
                 Array(val)
               elsif val.is_a?(Proc)
                 val.call
               else
                 val
               end
    end

    def value
      result = @value.nil? ? default : @value

      return "{#{result.join(',')}}" if array?

      result
    end

    def default
      @default.is_a?(Proc) ? @default.call : @default
    end
  end

  def self.bind(name, type, array: false, default: nil)
    binds[name] = QueryBind.new(name, type, array:, default:)
  end

  def self.binds
    @binds ||= {}.with_indifferent_access
  end

  def self.run(...)
    new(...).results
  end

  attr_reader :options, :query

  def initialize(options = {})
    @options = options.with_indifferent_access
    @query   = prepare_query
  end

  def base_query
    raise NotImplementedError
  end

  def results
    row_set = ApplicationRecord.connection.exec_query(query.squish, self.class.name, binds_values)
    row_set = row_set.map { |row| wrapper_class.new(**row) } if wrapper_class
    row_set.to_a
  end

  def binds
    @binds ||= self.class.binds.dup
  end

  def wrapper_class # rubocop:disable Rails/Delegate
    self.class.wrapper_class
  end

  def method_missing(name, *arguments, &)
    super unless options.key?(name) || binds.key?(name)

    self.class.define_singleton_method(name) do
      Rails.logger.warn(
        "Calling #{self.name}##{name} is deprecated because it is not a bind. Use options[:#{name}] instead."
      )

      options[name]
    end

    options[name]
  end

  def respond_to_missing?(name, *arguments, &)
    options.key?(name) || binds.key?(name) || super
  end

  private

  def prepare_query
    scope         = base_query
    current_index = 1

    binds.each_value do |param|
      value         = respond_to?(param.name, true) ? send(param.name) : options[param.name]
      param.value   = value
      param.present = false

      if scope.include?("@#{param.name}")
        param.present  = true
        param_index    = current_index
        current_index += 1
      end

      next scope = scope.gsub("@#{param.name}", "ANY ($#{param_index})") if param.array?

      scope = scope.gsub("@#{param.name}", "$#{param_index}")
    end

    scope
  end

  def binds_values
    @binds.values.select(&:present).map(&:value)
  end
end
