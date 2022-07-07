# frozen_string_literal: true

module CruftTracker
  class RecordBacktrace < CruftTracker::ApplicationService
    record :method, class: CruftTracker::Method

    private

    def execute
      return unless backtrace_record.present?

      CruftTracker::LogSuppressor.suppress_logging do
        backtrace_record.with_lock do
          backtrace_record.reload
          backtrace_record.update(occurrences: backtrace_record.occurrences + 1)
        end
      end

      backtrace_record
    end

    def backtrace_record
      @backtrace_record ||=
        begin
          return find_existing_backtrace_record if max_records_reached?

          CruftTracker::Backtrace.create(
            traceable: method,
            trace_hash: backtrace_hash,
            trace: filtered_backtrace
          )
        rescue ActiveRecord::RecordNotUnique
          find_existing_backtrace_record
        end
    end

    def find_existing_backtrace_record
      CruftTracker::Backtrace.find_by(trace_hash: backtrace_hash)
    end

    def backtrace_hash
      Digest::MD5.hexdigest(filtered_backtrace.to_json)
    end

    def filtered_backtrace
      last_locations_before_tracking_starts =
        caller_locations.reverse.find_index do |location|
          location.path.match(/.*track_method.*/)
        end

      caller_locations
        .last(last_locations_before_tracking_starts || 0)
        .map do |location|
          {
            path: location.path,
            label: location.label,
            base_label: location.base_label,
            lineno: location.lineno
          }
        end
    end

    def max_records_reached?
      CruftTracker::Backtrace.where(traceable: method).count >= CruftTracker.config.max_backtrace_variations_per_tracked_method
    end
  end
end
