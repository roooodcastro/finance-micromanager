# frozen_string_literal: true

class String
  def to_b
    %w[true 1 yes on t].include?(downcase)
  end
end

class NilClass
  def to_b
    false
  end
end

class TrueClass
  def to_b
    self
  end
end

class FalseClass
  def to_b
    self
  end
end

class Numeric
  def to_b
    self != 0
  end
end
