# frozen_string_literal: true

module CruftTracker
  class RecordArguments < CruftTracker::ApplicationService
    record :method, class: CruftTracker::Method
    array :arguments
    object :transformer, class: Proc

    private

    def execute
      CruftTracker::LogSuppressor.suppress_logging do
        return unless arguments_record.present?

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
          arguments_record = CruftTracker::Argument.find_by(
            method: method,
            arguments_hash: arguments_hash
          )

          if arguments_record.present? || max_records_reached?
            return arguments_record
          end

          CruftTracker::Argument.create(
            method: method,
            arguments_hash: arguments_hash,
            arguments: transformed_arguments
          )
        end
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
