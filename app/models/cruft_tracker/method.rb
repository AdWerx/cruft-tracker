# frozen_string_literal: true

module CruftTracker
  class Method < ActiveRecord::Base
    has_many :backtraces, class_name: 'CruftTracker::Backtrace', as: :traceable
    has_many :arguments, class_name: 'CruftTracker::Argument'

    # TODO: test me
    def still_exists?
      class_still_exists? && method_still_exists?
    end

    # TODO: test me
    def still_tracked?
      CruftTracker::Registry.instance.include?(self)
    end

    # TODO: test me
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
      when CruftTracker::TrackMethod::INSTANCE_METHOD.to_s
        (clazz.instance_methods + clazz.private_instance_methods)
      when CruftTracker::TrackMethod::CLASS_METHOD.to_s
        (clazz.methods + clazz.private_methods)
      end.include?(name.to_sym)
    end
  end
end
