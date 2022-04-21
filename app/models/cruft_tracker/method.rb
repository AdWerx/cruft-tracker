# frozen_string_literal: true

module CruftTracker
  class Method < ActiveRecord::Base
    INSTANCE_METHOD = :instance_method
    CLASS_METHOD = :class_method

    has_many :backtraces, class_name: 'CruftTracker::Backtrace', as: :traceable
    has_many :arguments, class_name: 'CruftTracker::Argument'

    def still_exists?
      class_still_exists? && method_still_exists?
    end

    def still_tracked?
      CruftTracker::Registry.instance.include?(self)
    end

    def ==(other)
      other.owner == owner && other.name == name &&
        other.method_type == method_type
    end

    private

    def class_still_exists?
      Object.const_defined?(owner)
    end

    def clazz
      owner.constantize
    end

    def method_still_exists?
      case method_type
      when CruftTracker::Method::INSTANCE_METHOD.to_s
        (clazz.instance_methods + clazz.private_instance_methods)
      when CruftTracker::Method::CLASS_METHOD.to_s
        (clazz.methods + clazz.private_methods)
      end.include?(name.to_sym)
    end
  end
end
