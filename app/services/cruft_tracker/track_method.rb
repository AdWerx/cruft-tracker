# frozen_string_literal: true

module CruftTracker
  class TrackMethod < ApplicationService
    INSTANCE_METHOD = :instance_method
    CLASS_METHOD = :class_method

    private

    object :owner, class: Module
    symbol :method_name
    symbol :method_type, default: -> { determine_method_type }

    def execute
      ensure_method_record_exists
      wrap_target_method(method_type, target_method)
    end

    def ensure_method_record_exists
      method_record
    end

    def method_record
      @method_record ||= create_or_find_method_record
    end

    def wrap_target_method(method_type, target_method)
      target_method.owner.define_method target_method.name do |*args|
        # IsThisUsed::Util::LogSuppressor.suppress_logging do
        #   CruftTracker::Recorder.record_invocation(potential_cruft)
        #   if track_arguments
        #     arguments =
        #       if track_arguments.instance_of?(Proc)
        #         track_arguments.call(args)
        #       else
        #         args
        #       end
        #
        #     CruftTracker::Recorder.record_arguments(potential_cruft, arguments)
        #   end
        # end
        puts '>>>> in wrapper'
        if method_type == INSTANCE_METHOD
          target_method.bind(self).call(*args)
        else
          target_method.call(*args)
        end
      end
    end

    def create_or_find_method_record
      CruftTracker::Method.find_or_create_by(
        owner_name: owner,
        method_name: method_name,
        method_type: method_type
      )
    rescue ActiveRecord::RecordNotUnique
      CruftTracker::Method.find_by(
        owner_name: owner,
        method_name: method_name,
        method_type: method_type
      )
    end

    def target_method
      case method_type
      when INSTANCE_METHOD
        owner.instance_method(method_name)
      when CLASS_METHOD
        owner.method(method_name)
      end
    end

    def determine_method_type
      is_instance_method = all_instance_methods.include?(method_name)
      is_class_method = all_class_methods.include?(method_name)

      if is_instance_method && is_class_method
        raise AmbiguousMethodType.new(owner.name, method_name)
      elsif is_instance_method
        INSTANCE_METHOD
      elsif is_class_method
        CLASS_METHOD
      else
        raise NoSuchMethod.new(owner.name, method_name)
      end
    end

    def all_instance_methods
      owner.instance_methods + owner.private_instance_methods
    end

    def all_class_methods
      owner.methods + owner.private_methods
    end

    class AmbiguousMethodType < StandardError
      def initialize(owner_name, ambiguous_method_name)
        super(
          "#{owner_name} has instance and class methods named '#{
            ambiguous_method_name
          }'. Please specify the correct type."
        )
      end
    end

    class NoSuchMethod < StandardError
      def initialize(owner_name, missing_method_name)
        super(
          "#{owner_name} does not have an instance or class method named '#{
            missing_method_name
          }'."
        )
      end
    end
  end
end