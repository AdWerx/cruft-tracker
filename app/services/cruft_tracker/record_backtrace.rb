# frozen_string_literal: true

module CruftTracker
  # TODO: test me?
  class RecordBacktrace < CruftTracker::ApplicationService
    record :method, class: CruftTracker::Method

    private

    def execute
      backtrace_record.with_lock do
        backtrace_record.reload
        backtrace_record.update(occurrences: backtrace_record.occurrences + 1)
      end

      backtrace_record
    end

    def backtrace_record
      @backtrace_record ||=
        begin
          CruftTracker::Backtrace.create(
            traceable: method,
            trace_hash: backtrace_hash,
            trace: filtered_backtrace
          )
        rescue ActiveRecord::RecordNotUnique
          CruftTracker::Backtrace.find_by(trace_hash: backtrace_hash)
        end
    end

    def backtrace_hash
      Digest::MD5.hexdigest(filtered_backtrace.to_json)
    end

    def filtered_backtrace
      drop_to_index =
        (
          caller_locations.find_index do |location|
            location.path.match(%r{cruft_tracker\/track_method})
          end || 0
        ) + 1

      caller_locations
        .drop(drop_to_index)
        .map do |location|
          {
            path: location.path,
            label: location.label,
            base_label: location.base_label,
            lineno: location.lineno
          }
        end
    end
  end
end
