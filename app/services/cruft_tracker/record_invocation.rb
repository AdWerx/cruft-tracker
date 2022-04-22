# frozen_string_literal: true

module CruftTracker
  class RecordInvocation < CruftTracker::ApplicationService
    record :method, class: CruftTracker::Method

    def execute
      CruftTracker::LogSuppressor.suppress_logging { increment_invocations }
    end

    def increment_invocations
      method.update(invocations: method.reload.invocations + 1)
    end
  end
end
