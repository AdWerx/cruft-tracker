# frozen_string_literal: true

module CruftTracker
  class RecordArguments < CruftTracker::ApplicationService
    record :method, class: CruftTracker::Method
    array :arguments
    object :transformer, class: Proc

    private

    def execute
      return unless arguments_record.present?

      CruftTracker::LogSuppressor.suppress_logging do
        arguments_record.with_lock do
          arguments_record.reload
          arguments_record.update(occurrences: arguments_record.occurrences + 1)
        end
      end

      arguments_record
    end

    def arguments_record
      @arguments_record ||=
        begin
          return find_existing_arguments_record if max_records_reached?

          CruftTracker::Argument.create(
            method: method,
            arguments_hash: arguments_hash,
            arguments: transformed_arguments
          )
        rescue ActiveRecord::RecordNotUnique
          find_existing_arguments_record
        end
    end

    def find_existing_arguments_record
      CruftTracker::Argument.find_by(arguments_hash: arguments_hash)
    end

    def arguments_hash
      Digest::MD5.hexdigest(transformed_arguments.to_json)
    end

    def transformed_arguments
      @transformed_arguments ||= transformer.call(arguments)
    end

    def max_records_reached?
      CruftTracker::Argument.where(method: method).count >= CruftTracker.config.max_argument_variations_per_tracked_method
    end
  end
end
