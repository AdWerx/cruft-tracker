# frozen_string_literal: true

module CruftTracker
  class TrackMethod < CruftTracker::ApplicationService
    private

    object :owner, class: Module
    symbol :name
    symbol :method_type, default: -> { determine_method_type }
    object :comment, class: Object, default: nil
    object :arguments_transformer, class: Proc, default: nil

    def execute
      method_record = create_or_find_method_record
      method_record.deleted_at = nil
      method_record.comment = comment if comment != method_record.comment
      method_record.save

      CruftTracker::Registry << method_record

      wrap_target_method(
        method_type,
        target_method,
        method_record,
        arguments_transformer
      )

      method_record
    rescue ActiveRecord::StatementInvalid => e
      raise unless e.cause.present? && e.cause.instance_of?(Mysql2::Error)

      Rails.logger.warn(
        'CruftTracker was unable to record a method. Does the cruft_tracker_methods table exist? Have migrations been run?'
      )
    rescue NoMethodError
      Rails.logger.warn(
        'CruftTracker was unable to record a method. Have migrations been run?'
      )
    rescue Mysql2::Error::ConnectionError,
           ActiveRecord::ConnectionNotEstablished
      Rails.logger.warn(
        'CruftTracker was unable to record a method due to being unable to connect to the database. This may be a non-issue in cases where the database is intentionally not available.'
      )
    end

    def wrap_target_method(
      method_type,
      target_method,
      method_record,
      arguments_transformer
    )
      target_method.owner.define_method target_method.name do |*args|
        CruftTracker::RecordInvocation.run!(method: method_record)
        CruftTracker::RecordBacktrace.run!(method: method_record)
        if arguments_transformer.present?
          CruftTracker::RecordArguments.run!(
            method: method_record,
            arguments: args,
            transformer: arguments_transformer
          )
        end
        if method_type == CruftTracker::Method::INSTANCE_METHOD
          target_method.bind(self).call(*args)
        else
          target_method.call(*args)
        end
      end
    end

    def create_or_find_method_record
      CruftTracker::Method.create(
        owner: owner.name,
        name: name,
        method_type: method_type,
        comment: comment
      )
    rescue ActiveRecord::RecordNotUnique
      CruftTracker::Method.find_by(
        owner: owner.name,
        name: name,
        method_type: method_type
      )
    end

    def target_method
      case method_type
      when CruftTracker::Method::INSTANCE_METHOD
        owner.instance_method(name)
      when CruftTracker::Method::CLASS_METHOD
        owner.method(name)
      end
    end

    def determine_method_type
      is_instance_method = all_instance_methods.include?(name)
      is_class_method = all_class_methods.include?(name)

      if is_instance_method && is_class_method
        raise AmbiguousMethodType.new(owner.name, name)
      elsif is_instance_method
        CruftTracker::Method::INSTANCE_METHOD
      elsif is_class_method
        CruftTracker::Method::CLASS_METHOD
      else
        raise NoSuchMethod.new(owner.name, name)
      end
    end

    def all_instance_methods
      owner.instance_methods + owner.private_instance_methods
    end

    def all_class_methods
      owner.methods + owner.private_methods
    end

    class AmbiguousMethodType < StandardError
      def initialize(owner_name, ambiguous_name)
        super(
          "#{owner_name} has instance and class methods named '#{
            ambiguous_name
          }'. Please specify the correct type."
        )
      end
    end

    class NoSuchMethod < StandardError
      def initialize(owner_name, missing_name)
        super(
          "#{owner_name} does not have an instance or class method named '#{
            missing_name
          }'."
        )
      end
    end
  end
end
