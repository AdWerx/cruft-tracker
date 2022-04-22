# frozen_string_literal: true

module CruftTracker
  class RecordArguments < CruftTracker::ApplicationService
    record :method, class: CruftTracker::Method
    array :arguments
    object :transformer, class: Proc

    private

    def execute
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
          CruftTracker::Argument.create(
            method: method,
            arguments_hash: arguments_hash,
            arguments: transformed_arguments
          )
        rescue ActiveRecord::RecordNotUnique
          CruftTracker::Argument.find_by(arguments_hash: arguments_hash)
        end
    end

    def arguments_hash
      Digest::MD5.hexdigest(transformed_arguments.to_json)
    end

    def transformed_arguments
      @transformed_arguments ||= transformer.call(arguments)
    end
  end
end
