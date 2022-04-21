# frozen_string_literal: true

module CruftTracker
  class RecordInvocation < CruftTracker::ApplicationService
    record :method, class: CruftTracker::Method

    def execute
      increment_invocations
    end

    def increment_invocations
      CruftTracker::Method.increment_counter(
        :invocations,
        method.id,
        touch: true
      )
    end
  end
end
