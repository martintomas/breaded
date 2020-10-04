# frozen_string_literal: true

class BaseType < ActiveRecord::Base
  self.abstract_class = true

  validates :code, presence: true
  validates :code, uniqueness: true

  def self.method_missing(method_name, *args)
    super unless method_name.to_s.start_with? 'the_'
    begin
      Thread.current["#{name}_#{method_name}"] ||= find_by!(code: method_name.to_s[4..-1])
    rescue ActiveRecord::RecordNotFound
      super
    end
  end

  def to_s
    code
  end
end
