# frozen_string_literal: true

module CruftTracker
  # TODO: test me?
  class RecordInvocation < ApplicationService
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
